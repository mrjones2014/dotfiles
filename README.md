# Dotfiles

These are my NixOS and macOS dotfiles, packaged as a Nix flake using [`home-manager`](https://github.com/nix-community/home-manager)
and [nix-darwin](https://github.com/nix-darwin/nix-darwin) on macOS.

For info on how to set up my Nix flake, see the [setup instructions](https://mjones.network/my-dotfiles.html).

These Nix configs currently manage:

**NixOS + `home-manager`:**

- My homelab server (`.#mikoshi`)
- My desktop PC (`.#edgerunner`)
- My Thinkpad laptop (`.#kabuki`)

**`nix-darwin` + `home-manager`:**

- My work MacBook Pro (`.#corpo`)
- My personal MacBook Air (`.#aldecaldo`)

## Caveats

I try my best to make things work for both macOS and Linux (NixOS), please let me know if something does not work.
