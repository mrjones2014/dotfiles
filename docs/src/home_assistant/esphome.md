# ESPHome is very cool

I have this [cheap Amazon lamp](https://www.amazon.com/dp/B0CDGF12NR/). I wanted
it to be a smart lamp so I could control it in sync with the rest of the lights
in my home office. It comes with a 433MHz RF remote, something I figured I could
easily replicate with a programmable device.

ESPHome is the perfect tool for that. I purchased [this ESPHome RF/IR
remote](https://www.athom.tech/blank-1/esphome-rf433-ir-remote-controller),
which has RF and IR transmitters and receivers on an ESP32, pre-flashed with
ESPHome. [xtai/py-rf-lights](https://github.com/xtai/py-rf-lights) reverse
engineered the same family of lamp and was a big help.

## Capturing the codes

The Athom firmware ships with `dump: all` on the receivers. Open the device logs,
press buttons on the remote, and the codes fall out:

```
[remote.rc_switch] Received RCSwitch Raw: protocol=6 data='001101000110110100000001'
```

Each button is a 24-bit code. The first 20 bits are the remote's address (the
lamp is paired to this) and the last 4 identify the button:

```
001101000110110100000001  power toggle
001101000110110100001001  cycle color temp
001101000110110100000100  brightness up
001101000110110100001000  brightness down
```

Brightness works by holding the button, and "holding" over RF just means the
remote repeats the frame for as long as you press. The lamp steps through its
brightness levels while frames keep arriving. So setting a brightness from
software means sending the up or down code N times.

## Don't trust the protocol label

The obvious next step is `remote_transmitter.transmit_rc_switch_raw` with
`protocol: 6`, since that's what the receiver labeled it. The lamp ignores that
entirely. The receive-side decoder is tolerant and will stamp "protocol 6" on
anything with roughly the right shape, but ESPHome transmits protocol 6 with a
450µs pulse at a 1:2 ratio, and this remote actually sends ~232/760µs at a 1:3
ratio. The chip in the lamp only accepts the real thing.

So capture the actual waveform instead. Set the receiver to dump raw timings
(the `!extend` reaches into Athom's packaged config):

```yaml
remote_receiver:
  - id: !extend rf_receiver
    dump: raw
    idle: 60ms
```

Press a button on the remote once and you get the microsecond-level mark/space
durations of the real signal:

```
[remote.raw] Received Raw: ... -232, 760, -712, 286, ... 229, -7617, ...
```

Two gotchas when reading these dumps:

1. The Athom's receiver pin is configured `inverted: true`, which flips the
   signs. What prints as negative is actually carrier-on. If you replay the dump
   literally you transmit the waveform upside down. I verified polarity by
   transmitting and capturing my own signal next to the remote's (the receiver
   hears the transmitter from 2cm away, which makes a decent free logic
   analyzer) and diffing them.
2. The remote's frame ends with a stubby ~230µs pulse before the long silence.
   That's not noise. It's the pilot of the HT6P20B-style encoder these remotes
   use: one short pulse and ~23 pulse-widths of silence that arms the receiving
   chip before the data bits. Leave it out and the lamp discards everything that
   follows, no matter how perfect the bits are. This cost me days.

The complete frame, repeated ~6 times per press (the real remote sends 5, and the
first frame always gets mangled by receiver gain settling, so redundancy is part
of the protocol):

```
PILOT                    24 DATA BITS
┌─┐                      ┌─┐    ┌────┐
│ │                      │ │    │    │
┘ └──────────────────────┘ └────┘    └── ...
232µs ON, 7600µs OFF     bit 0: 232µs ON + 760µs OFF
                         bit 1: 712µs ON + 286µs OFF
```

One more warning: if you build frames in a lambda, make sure the timing values
strictly alternate positive and negative. Static YAML arrays are validated for
this, lambda output is not, and a malformed array goes straight to the RMT driver
and hard-crashes the ESP32 with `IllegalInstruction`. A crash-looping ESP takes
its receivers down too, which makes everything else confusing to debug.

## Masquerading as a light device

This exposes the lamp as a dimmable light in Home Assistant, and through the
HomeKit bridge Siri can control it. RF is one-way, so the config tracks assumed
state in globals and translates state changes into button presses. Power is a
toggle, dimming is emulated button-holding (my lamp has about 4 brightness
levels), and if the physical remote or foot switch desyncs things, you put the
lamp at a known state and press the Resync button.

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

If you have a different unit of the same lamp, the codes won't match yours. The
20-bit address is per-remote. Capture your own with `dump: all` and swap the
four code strings; the timings and pilot should carry over.

## It has an IR blaster too

After the lamp worked, I noticed the Athom box still had the IR side doing
nothing. My office AC is an old window unit with a dumb remote. I forget to turn
it off constantly, and turning it off overnight saves energy, but then the room
is too hot by morning. Home Assistant is a better place for that logic.

IR has the same basic shape as the lamp problem: Home Assistant sends button
presses, and the ESP tracks what it thinks the AC state is. There is no feedback
from the AC, so it still needs a resync button for when the real remote or the
buttons directly on it get used.

With `dump: all`, ESPHome's NEC decoder was enough for this remote. The logs also
had Pronto dumps and a few other decoder guesses, but the NEC line is the one I
used with `remote_transmitter.transmit_nec`:

```
[remote.nec] Received NEC: address=0x6681, command=0x7E81 command_repeats=1
[remote.nec] Received NEC: address=0x6681, command=0x649B command_repeats=1
[remote.nec] Received NEC: address=0x6681, command=0x758A command_repeats=1
[remote.nec] Received NEC: address=0x6681, command=0x7A85 command_repeats=1
[remote.nec] Received NEC: address=0x6681, command=0x6699 command_repeats=1
```

Those five buttons are all I need:

```
0x7E81  power
0x649B  mode
0x758A  temp down
0x7A85  temp up
0x6699  fan
```

On my unit, power always wakes it into e-save. I only ever want cool mode from
Home Assistant, so turn-on sends power, waits a bit, then presses mode once.
Temperature is direct enough because the remote has separate up/down buttons. Fan
speed is more annoying because it is a single cycle button, so the config keeps
the last assumed speed and sends 0, 1, or 2 presses to get to the target.

These are the AC bits I added alongside the floor light config above. Merge
top-level keys with those from the light config above.

```yaml
globals:
  - id: ac_setpoint # assumed setpoint in F
    type: int
    restore_value: true
    initial_value: "70"
  - id: ac_fan # assumed fan speed, 1 to 3
    type: int
    restore_value: true
    initial_value: "1"
script:
  - id: ac_press
    mode: queued
    parameters:
      command: int
      count: int
    then:
      - repeat:
          count: !lambda "return count;"
          then:
            - remote_transmitter.transmit_nec:
                transmitter_id: ir_transmitter
                address: 0x6681
                command: !lambda "return command;"
                command_repeats: 1
            - delay: 350ms
switch:
  - platform: template
    name: "AC Power"
    id: ac_power
    optimistic: true
    restore_mode: RESTORE_DEFAULT_OFF
    icon: mdi:air-conditioner
    turn_on_action:
      - script.execute:
          id: ac_press
          command: 0x7E81
          count: 1
      - delay: 1500ms
      - script.execute:
          id: ac_press
          command: 0x649B
          count: 1
    turn_off_action:
      - script.execute:
          id: ac_press
          command: 0x7E81
          count: 1
number:
  - platform: template
    name: "AC Temperature"
    id: ac_temp
    min_value: 61
    max_value: 86
    step: 1
    unit_of_measurement: "F"
    icon: mdi:thermometer
    lambda: "return id(ac_setpoint);"
    update_interval: 60s
    set_action:
      - lambda: |-
          int target = (int) roundf(x);
          int cur = id(ac_setpoint);
          if (!id(ac_power).state) {
            id(ac_temp).publish_state(cur);
            return;
          }
          int delta = target - cur;
          if (delta > 0) {
            id(ac_press)->execute(0x7A85, delta);
          } else if (delta < 0) {
            id(ac_press)->execute(0x758A, -delta);
          }
          id(ac_setpoint) = target;
          id(ac_temp).publish_state(target);
select:
  - platform: template
    name: "AC Fan Speed"
    id: ac_fan_sel
    options: ["1", "2", "3"]
    lambda: "return std::to_string(id(ac_fan));"
    update_interval: 60s
    set_action:
      - lambda: |-
          int target = std::stoi(x);
          if (!id(ac_power).state) {
            id(ac_fan_sel).publish_state(std::to_string(id(ac_fan)));
            return;
          }
          int presses = (target - id(ac_fan) + 3) % 3;
          if (presses > 0) id(ac_press)->execute(0x6699, presses);
          id(ac_fan) = target;
          id(ac_fan_sel).publish_state(std::to_string(target));
button:
  - platform: template
    name: "AC Resync"
    on_press:
      - lambda: |-
          id(ac_setpoint) = 70;
          id(ac_fan) = 1;
          id(ac_temp).publish_state(70);
          id(ac_fan_sel).publish_state("1");
      - switch.template.publish:
          id: ac_power
          state: ON
```

The ESPHome entities already work in Home Assistant, but HomeKit Bridge exposes
`climate` entities as thermostats. A bare switch, number, and select show up as
three separate controls. I used
[hass-template-climate](https://github.com/jcwillox/hass-template-climate) to
wrap them into one climate device.

I install that component in my NixOS Home Assistant service. The climate entry
looks like this:

```nix
{
  services.home-assistant.config.climate = [
    {
      platform = "climate_template";
      name = "Window AC";
      unique_id = "window_ac_climate";
      modes = [
        "off"
        "cool"
      ];
      fan_modes = [
        "low"
        "medium"
        "high"
      ];
      min_temp = 61;
      max_temp = 86;
      temp_step = 1;

      # Read state from the ESPHome entities.
      hvac_mode_template = "{{ 'cool' if is_state('switch.office_ac_power', 'on') else 'off' }}";
      target_temperature_template = "{{ states('number.office_ac_temperature') | float(70) }}";
      # Apple Home only recognizes fan speed low/medium/high not 1/2/3
      fan_mode_template = "{{ {'1': 'low', '2': 'medium', '3': 'high'}.get(states('select.office_ac_fan_speed'), 'low') }}";

      # Write state back to the ESPHome entities.
      set_hvac_mode = [
        {
          service = "{{ 'switch.turn_on' if hvac_mode == 'cool' else 'switch.turn_off' }}";
          target.entity_id = "switch.office_ac_power";
        }
      ];
      set_temperature = [
        {
          service = "number.set_value";
          target.entity_id = "number.office_ac_temperature";
          data.value = "{{ temperature }}";
        }
      ];
      set_fan_mode = [
        {
          service = "select.select_option";
          target.entity_id = "select.office_ac_fan_speed";
          data.option = "{{ {'low': '1', 'medium': '2', 'high': '3'}[fan_mode] }}";
        }
      ];
    }
  ];
}
```

With normal Home Assistant YAML, this is the same `climate:` entry in YAML
syntax. Entity IDs are the part you have to change.

## Acknowledgements

These helped:

- [xtai/py-rf-lights](https://github.com/xtai/py-rf-lights)
- [jcwillox/hass-template-climate](https://github.com/jcwillox/hass-template-climate)
