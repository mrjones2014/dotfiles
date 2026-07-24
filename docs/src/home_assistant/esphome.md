# ESPHome is very cool

I have this [cheap Amazon lamp](https://www.amazon.com/dp/B0CDGF12NR/). I wanted it to be a smart lamp so I could control it in sync with the rest of the lights in my home office. It comes with a 433MHz RF remote, so the whole job is capturing what the remote transmits and replaying it.

ESPHome is the perfect tool for that. I purchased [this ESPHome RF/IR remote](https://www.athom.tech/blank-1/esphome-rf433-ir-remote-controller), which has RF and IR transmitters and receivers on an ESP32, pre-flashed with ESPHome. [xtai/py-rf-lights](https://github.com/xtai/py-rf-lights) reverse engineered the same family of lamp and was a big help.

## Capturing the codes

The Athom firmware ships with `dump: all` on the receivers. Open the device logs, press buttons on the remote, and the codes fall out:

```
[remote.rc_switch] Received RCSwitch Raw: protocol=6 data='001101000110110100000001'
```

Each button is a 24-bit code. The first 20 bits are the remote's address (the lamp is paired to this) and the last 4 identify the button:

```
001101000110110100000001  power toggle
001101000110110100001001  cycle color temp
001101000110110100000100  brightness up
001101000110110100001000  brightness down
```

Brightness works by holding the button, and "holding" over RF just means the remote repeats the frame for as long as you press. The lamp steps through its brightness levels while frames keep arriving. So setting a brightness from software means sending the up or down code N times.

## Don't trust the protocol label

The obvious next step is `remote_transmitter.transmit_rc_switch_raw` with `protocol: 6`, since that's what the receiver labeled it. The lamp ignores that entirely. The receive-side decoder is tolerant and will stamp "protocol 6" on anything with roughly the right shape, but ESPHome transmits protocol 6 with a 450µs pulse at a 1:2 ratio, and this remote actually sends ~232/760µs at a 1:3 ratio. The chip in the lamp only accepts the real thing.

So capture the actual waveform instead. Set the receiver to dump raw timings (the `!extend` reaches into Athom's packaged config):

```yaml
remote_receiver:
  - id: !extend rf_receiver
    dump: raw
    idle: 60ms
```

Press a button on the remote once and you get the microsecond-level mark/space durations of the real signal:

```
[remote.raw] Received Raw: ... -232, 760, -712, 286, ... 229, -7617, ...
```

Two gotchas when reading these dumps:

1. The Athom's receiver pin is configured `inverted: true`, which flips the signs. What prints as negative is actually carrier-on. If you replay the dump literally you transmit the waveform upside down. I verified polarity by transmitting and capturing my own signal next to the remote's (the receiver hears the transmitter from 2cm away, which makes a decent free logic analyzer) and diffing them.
2. The remote's frame ends with a stubby ~230µs pulse before the long silence. That's not noise. It's the pilot of the HT6P20B-style encoder these remotes use: one short pulse and ~23 pulse-widths of silence that arms the receiving chip before the data bits. Leave it out and the lamp discards everything that follows, no matter how perfect the bits are. This cost me days.

The complete frame, repeated ~6 times per press (the real remote sends 5, and the first frame always gets mangled by receiver gain settling, so redundancy is part of the protocol):

```
PILOT                    24 DATA BITS
┌─┐                      ┌─┐    ┌────┐
│ │                      │ │    │    │
┘ └──────────────────────┘ └────┘    └── ...
232µs ON, 7600µs OFF     bit 0: 232µs ON + 760µs OFF
                         bit 1: 712µs ON + 286µs OFF
```

One more warning: if you build frames in a lambda, make sure the timing values strictly alternate positive and negative. Static YAML arrays are validated for this, lambda output is not, and a malformed array goes straight to the RMT driver and hard-crashes the ESP32 with `IllegalInstruction`. A crash-looping ESP takes its receivers down too, which makes everything else confusing to debug.

## The config

This exposes the lamp as a dimmable light in Home Assistant, and through the HomeKit bridge Siri can control it. RF is one-way, so the config tracks assumed state in globals and translates state changes into button presses. Power is a toggle, dimming is emulated button-holding (my lamp has about 4 brightness levels), and if the physical remote or foot switch desyncs things, you put the lamp at a known state and press the Resync button.

```yaml
# Floor Light (hanaking)
# Paste at the bottom of the device YAML (after your WiFi configs and such).
globals:
  - id: floor_light_power
    type: bool
    restore_value: true
    initial_value: "true"
  - id: floor_light_bri # assumed brightness percent
    type: int
    restore_value: true
    initial_value: "100"
script:
  - id: floor_light_send
    mode: queued
    parameters:
      code: string
      times: int
    then:
      - remote_transmitter.transmit_raw:
          transmitter_id: rf_transmitter
          code: !lambda |-
            std::vector<int32_t> t;
            t.reserve(2 + code.size() * 2);
            t.push_back(232);      // pilot pulse
            t.push_back(-7600);    // pilot silence
            for (char c : code) {
              if (c == '1') { t.push_back(712); t.push_back(-286); }
              else          { t.push_back(232); t.push_back(-760); }
            }
            return t;
          repeat:
            times: !lambda "return times;"
            wait_time: 0s
output:
  - platform: template
    id: floor_light_bri_out
    type: float
    write_action:
      - lambda: |-
          static const char *PWR = "001101000110110100000001";
          static const char *UP  = "001101000110110100000100";
          static const char *DN  = "001101000110110100001000";
          bool t_power = state > 0.005f;
          int t_bri = (int) roundf(state * 100.0f);
          if (t_power && t_bri < 10) t_bri = 10;   // lamp floor is 10%
          int c_bri = id(floor_light_bri);
          if (id(floor_light_power) && !t_power) {
            id(floor_light_send)->execute(PWR, 6);
            id(floor_light_power) = false;
            return;
          }
          if (!t_power) return;
          if (!id(floor_light_power)) {
            id(floor_light_send)->execute(PWR, 6);
            id(floor_light_power) = true;
          }
          // Dimming: scale hold-frames to the size of the change.
          // Calibrate FRAMES_PER_PCT to your lamp: if HA's 50% lands
          // too dim, lower it; too bright, raise it.
          const float FRAMES_PER_PCT = 1.0f;
          int delta = t_bri - c_bri;
          if (delta != 0) {
            int n = (int) roundf(fabsf((float) delta) * FRAMES_PER_PCT);
            if (n < 4) n = 4;                      // minimum visible nudge
            id(floor_light_send)->execute(delta > 0 ? UP : DN, n);
          }
          id(floor_light_bri) = t_bri;
light:
  - platform: monochromatic
    name: "Floor Light"
    output: floor_light_bri_out
    gamma_correct: 1.0
    default_transition_length: 0s
button:
  - platform: template
    name: "Floor Light Cycle Color Temp"
    on_press:
      - script.execute:
          id: floor_light_send
          code: "001101000110110100001001"
          times: 6
  # Put the lamp at a known state (on, full brightness), then press this
  - platform: template
    name: "Floor Light Resync"
    on_press:
      - lambda: |-
          id(floor_light_power) = true;
          id(floor_light_bri) = 100;
```

If you have a different unit of the same lamp, the codes won't match yours. The 20-bit address is per-remote. Capture your own with `dump: all` and swap the four code strings; the timings and pilot should carry over.
