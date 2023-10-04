# Dotfiles

These are my NixOS and macOS dotfiles, packaged as a Nix flake, using [`home-manager`](https://github.com/nix-community/home-manager).

For info on how to set up my Nix flake, see the [setup instructions](https://mjones.network/my-dotfiles.html).

## Why a Nix Flake

Nix is an incredibly complex piece of software, but despite that, I believe that Nix is the only sensible way to manage software today. Using Nix, and particularly a Nix
flake, offers a few unique benefits:

1. **Reproducibility**: Nix environments are described by text files (`*.nix` files), and as long as you stay within the guard rails, the environment should be deterministic.
2. **Isolation**: Packages can have access to their dependencies without those dependencies cluttering up the global environment &mdash; this also means different packages can depend on different versions of the same dependency without conflicts.
3. **Rollbacks**: Totally screw up your environment by accident? Just roll back to a previous generation.
4. **Immutability**: Any changes to your environment can/should be done via Nix, allowing the environment to remain immutable, reproducible, and deterministic.

Additionally, no manual symlinking is required, and no treating your `$HOME` directory as a git repo. My dotfiles just live at `~/git/dotfiles/` and Nix handles putting everything into place and keeping it up to date immutably.
Nix also supports Linux, NixOS, and macOS, which are the only operating systems I use.

## Caveats

I try my best to make things work for both macOS and Linux (NixOS), please let me know if something does not work.
Windows is absolutely not supported, since Nix does not support Windows. [Microsoft Windows itself is malware/spyware](https://www.gnu.org/proprietary/malware-microsoft.html) anyway.
