# Installing on a New System

First, [install Nix package manager](https://nixos.org/download.html#download-nix) (unless you're on NixOS where it's pre-installed).
Then, use Nix to [install `home-manager`](https://nix-community.github.io/home-manager/index.html#ch-installation).

Once you have those installed, do the following:

```bash
mkdir -p "$HOME/git"
cd "$HOME/git"
git clone git@github.com:mrjones2014/dotfiles.git
```

Then, open `./home-manager/modules/fish.nix`, copy the `nix-apply` alias definition for your system, and run it.

Restart your terminal, then run `sudo vi /etc/shells` and add the output of `which fish` as a new entry. Then run `chsh -S $(which fish)`
to change the default shell. You may have to log out and back in after this.

If you're on macOS, after installing Hammerspoon, run `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`.

## Configuring Git

In order to keep my email addresses and signing key IDs out of version control, I `includeIf` them from separate
configs for work vs. personal development. Set `user.email` and `user.signingkey` in `~/.config/git/gitconfig.gitlab`
and `~/.config/git/gitconfig.github` (which are not tracked in git). Commit signing is done via the 1Password SSH
agent with SSH keys. To configure, go to the SSH key item in 1Password, then from the context menu, select
"Configure commit signing", then copy the `signingkey` line, and place it under the `[user]` section in
`~/.config/git/gitconfig.github` or `~/.config/git/gitconfig.gitlab`. It should look something like this:

```gitconfig
[user]
  signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrtS+BUQ9qm1vBQI8yyfhSnN0C3mSXroM0adXdM7x76
  email = "your.address@email.com"
```

Note that this is the public key for a fake SSH key that is not in use anywhere and has been deleted from 1Password.

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager);

## Caveats

Neovim configuration may require Neovim nightly depending on where Neovim's release cycle is at.

I try my best to make things work for both macOS and Linux, please let me know if something does not work.
Windows is absolutely not supported. [Microsoft Windows itself is malware/spyware](https://www.gnu.org/proprietary/malware-microsoft.html) anyway.
