# Installing on a New System

```bash
mkdir -p "$HOME/git"
cd "$HOME/git"
git clone git@github.com:mrjones2014/dotfiles.git
```

Then run the `./init.bash` script from the repo. This will:

- Install Nix if it is not already installed.
- Install `home-manager` if it is not already installed.
- Create the initial Nix generation
- On macOS, it will also:
  - Configure Hammerspoon to look for config in `$XDG_CONFIG_HOME/hammerspoon` instead of `$HOME/.hammerspoon`.
  - Optionally, with confirmation from user, set up a bunch of macOS default settings to more sane defaults.

Then, open `./home-manager/modules/fish.nix`, copy the `nix-apply` alias definition for your system, and run it.
For first time setup, you will likely need to prefix the command with `NIX_CONFIG="experimental-features = nix-command flakes"`
to set the Nix config to allow the `nix flake` command via the `NIX_CONFIG` environment variable. After initial setup,
this is set by the `conf.f/nix.conf` file (which is placed at `$XDG_CONFIG_HOME/nix/nix.conf`).

On macOS, you also have to manually change the default shell to Fish.

- Run `which fish` to get the filepath to the Fish binary (should be something like `$HOME/.nix-profile/bin/fish`)
- Run `sudo vi /etc/shells` and add the output of `which fish` as an entry, then write the file and quit
- Run `chsh -s $(which fish)`
- Log out and back in

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager).
On NixOS, the `home-manager` configuration is managed as a NixOS module, so simply rebuilding your NixOS config also applies the new
`home-manager` config. On macOS, you only have `nix` and `home-manager` so use the `home-manager` CLI directly.
