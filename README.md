# Installing on a New System

First, [install Nix package manager](https://nixos.org/download.html#download-nix) (unless you're on NixOS where it's pre-installed).
Then, use Nix to [install `home-manager`](https://nix-community.github.io/home-manager/index.html#ch-installation).

Once you have those installed, do the following:

```bash
mkdir -p "$HOME/git"
cd "$HOME/git"
git clone git@github.com:mrjones2014/dotfiles.git
```

Run the `./init.bash` script from the repo. This will:

- Install Nix if it is not already installed.
- Install `home-manager` if it is not already installed.
- Create the initial Nix generation
- On macOS, it will also:
  - Configure Hammerspoon to look for config in `$XDG_CONFIG_HOME/hammerspoon` instead of `$HOME/.hammerspoon`.
  - Optionally, with confirmation from user, set up a bunch of macOS default settings to more sane defaults.

Then, open `./home-manager/modules/fish.nix`, copy the `nix-apply` alias definition for your system, and run it.

Restart your terminal, then run `sudo vi /etc/shells` and add the output of `which fish` as a new entry. Then run `chsh -S $(which fish)`
to change the default shell. You may have to log out and back in after this.

If you're on macOS, after installing Hammerspoon, run `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`.

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager);

## Caveats

Neovim configuration may require Neovim nightly depending on where Neovim's release cycle is at.

I try my best to make things work for both macOS and Linux, please let me know if something does not work.
Windows is absolutely not supported. [Microsoft Windows itself is malware/spyware](https://www.gnu.org/proprietary/malware-microsoft.html) anyway.
