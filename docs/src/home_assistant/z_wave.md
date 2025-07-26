# Z Wave

Z Wave devices are a great alternative to WiFi based devices. WiFi devices suck,
and usually depend on some manufacturer's shitty app. Z Wave only relies on my own
server which has a USB Z-Wave controller plugged into it.

## Configuring Z-Wave JS UI

On initial setup, you have to tell it, through the UI unfortunately
(I haven't gotten it to work through the Nix config), what serial port the Z-Wave
controller is plugged into. On NixOS specifically, this is easy:

```bash
ls /dev/serial/by-id
# this will likely output something like, for example mine:
usb-Zooz_800_Z-Wave_Stick_533D004242-if00

# then find where that's pointing
realpath /dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00
# will output, for example
/dev/ttyACM0
```

On general Linux it's a bit more manual:

```bash
# unplug the controller
ls /dev/ttyUSB* /dev/ttyACM* > before
# plug in the controller
ls /dev/ttyUSB* /dev/ttyACM* > after
# diff the results
nix run nixpkgs#delta before after
```

## Z-Wave Devices

If a device becomes "dead" in Z-Wave JS UI, you probably just need to delete and re-add the device to the network.

Putting the device into "add" mode or "interview" mode varies by device. Here's some that I have:

- Minoston Z-Wave Outdoor Smart Plug: Triple click the button
