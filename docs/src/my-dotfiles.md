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
After the first time, you can just run `sudo nixos-rebuild switch --flake $HOME/git/dotfiles/.#pc` (or the `nix-apply` shell alias).

## macOS

On macOS, for the first install, you'll need to run `nix-darwin` via `nix run`:

```bash
nix run nix-darwin/master#darwin-rebuild -- switch --extra-experimental-features "nix-command flakes" --flake $HOME/git/dotfiles
```

After that, you can just run `darwin-rebuild switch --flake $HOME/git/dotfiles` (or the `nix-apply` shell alias).

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager).
On NixOS, the `home-manager` configuration is managed as a NixOS module, so simply rebuilding your NixOS config also applies the new
`home-manager` config. On macOS, the same behavior is achieved via [nix-darwin](https://github.com/nix-darwin/nix-darwin).
