# Installing on a New System

```bash
mkdir -p "$HOME/git"
cd "$HOME/git"
git clone git@github.com:mrjones2014/dotfiles.git
```

## NixOS

If you're installing on a server, see the [NixOS manual](https://nixos.org/manual/nixos/stable/#ch-installation) for headless NixOS installation instructions first.
Once you've got your disks partitioned and NixOS installed, come back here and continue. For desktop computers, you can just use the graphical GNOME NixOS installer,
since we'll be installing GNOME anyway.

Simply run `NIX_CONFIG="experimental-features = nix-command flakes" sudo nixos-rebuild switch ~/git/dotfiles/.#pc` (replacing `.#pc` with your desired flake output target).
After the first time, you won't need the `NIX_CONFIG=` part, as the flake will set that up in `$XDG_CONFIG_HOME/nix/nix.conf`.

## macOS

On macOS, you will need to [install the `home-manager` CLI manually](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone).
Then, you can run `home-manager switch --flake ~/git/dotfiles/.#pc` (replacing `.#pc` with your desired flake output target).

On macOS, you should then also run the following:

```sh
# configure Hammerspoon.app to look for its config file in `$XDG_CONFIG_HOME/hammerspoon` instead of `$HOME/.hammerspoon`
defaults write org.hammerspoon.Hammerspoon MJConfigFile "${XDG_CONFIG_HOME:-$HOME/.config}/hammerspoon/init.lua"
# Run a script to set up a lot of macOS settings to more sensible defaults
~/git/dotfiles/conf.d/setup-macos-defaults.bash
```

On macOS, you also have to manually change the default shell to Fish.

- Run `which fish` to get the filepath to the Fish binary (should be something like `$HOME/.nix-profile/bin/fish`)
- Run `sudo vi /etc/shells` and add the output of `which fish` (usually this should be something like `$HOME/.nix-profile/bin/fish`) as an entry, then write the file and quit
- Run `chsh -s $(which fish)`
- Log out and back in

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager).
On NixOS, the `home-manager` configuration is managed as a NixOS module, so simply rebuilding your NixOS config also applies the new
`home-manager` config. On macOS, you only have `nix` and `home-manager` so use the `home-manager` CLI directly.
