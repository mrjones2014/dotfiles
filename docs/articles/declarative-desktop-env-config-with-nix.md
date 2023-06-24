# Declarative Configuration for Desktop Environments on NixOS

As soon as I tried out Nix, I wanted to use Nix for _everything._ With Nix, all your configuration is _reproducible_ (as long as you
stay in pure mode, that is), which is amazing if you need to share configurations across devices.

For the sake of this article, I'll assume you have a working knowledge of Nix and NixOS.

## Getting Started

Building on top of Nix, [`home-manager`](https://github.com/nix-community/home-manager) is great for managing non-global packages
and dotfiles. It also has a module called `dconf` that allows you to declaratively define [`gsettings`](https://wiki.gnome.org/HowDoI/GSettings), a settings system for GNOME and related desktop environments.

Using the `dconf` module, you can configure everything from your system dark theme, desktop background image, and global keyboard
shortcuts declaratively using Nix.

First you need to enable `dconf`; in your `/etc/nixos/configuration.nix` or `flake.nix` add:

```nix
{ pkgs, ... }: { programs.dconf.enable = true; }
```

Then, in your `home-manager` configuration, you can start configuring your desktop environment using `dconf`.

```nix
{ pkgs, ... }: {
  dconf.settings = {
    # place your dconf settings here
    "some/settings/namespace" = { some-setting = "some-value"; };
  };
}
```

## Finding the Correct Settings Namespaces and Keys

Now that you've enabled `dconf` in your NixOS configuration, we can use `dconf` from the command line to figure out what the
namespaces and keys are for the settings you want to set declaratively in Nix. To do this, open a new terminal window and run
`dconf watch /`. This will start a process which will output any settings value that changes.

Now, change your desired settings from the settings GUI, and observe the output from `dconf watch /`. For example,
changing your wallpaper image from the settings GUI should output something like:

```
/org/gnome/desktop/background/picture-uri
  'file:///home/mat/.local/share/backgrounds/2023-06-15-14-59-58-wallpaper.jpg'
```

## Declarative Settings

With this information, you can set your desktop wallpaper declaratively within your `home-manager` configuration. You can use
`pkgs.fetchurl` to fetch the desired image file and set it as your desktop wallpaper:

```nix
{ pkgs, ... }:
let
  wallpaperImg = pkgs.fetchurl {
    url = "https://url/to/your/image";
    # replace this with the SHA256 hash of the image file
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  };
in {
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaperImg}";
    };
  };
}
```

With this added, applying your `home-manager` configuration will change your desktop wallpaper!
You can use this method to find just about all the settings you'll need, although some of them might
require some fiddling with.

For example, creating custom keyboard shortcuts is slightly more complex. First, you have to specify
each custom shortcut group that should exist, then you can specify the shortcuts themselves. For example:

```nix
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # specify that custom shortcut "custom0" should exist and be included
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
      terminal = [ "" ];
    };
    # now you can specify the "custom0" shortcut itself
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "Print"; # printscrn key
        command = "flameshot gui";
        name = "flameshot";
      };
  };
}
```

Feel free to take a look at all the current settings I use at time of writing [in my dotfiles repo](https://github.com/mrjones2014/dotfiles/tree/e3d1dc94b8cbfd108fa22e9bf58e77dca48bc70c/home-manager/modules/gnome).
