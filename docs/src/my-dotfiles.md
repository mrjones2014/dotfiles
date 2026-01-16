# Installing on a New System

```bash
mkdir -p "$HOME/git"
cd "$HOME/git"
git clone git@github.com:mrjones2014/dotfiles.git
cd "dotfiles/"
jj git init --colocate # if you use Jujutsu
```

## Available Hosts

| Host         | Type  | Description          |
| ------------ | ----- | -------------------- |
| `mikoshi`    | NixOS | Homelab server       |
| `edgerunner` | NixOS | Desktop PC           |
| `kabuki`     | NixOS | Thinkpad laptop      |
| `corpo`      | macOS | Work MacBook Pro     |
| `aldecaldo`  | macOS | Personal MacBook Air |

## NixOS

If you're installing on a server, see the [NixOS manual](https://nixos.org/manual/nixos/stable/#ch-installation) for headless NixOS installation instructions first.
Once you've got your disks partitioned and NixOS installed, come back here and continue. For desktop computers, you can just use the graphical GNOME NixOS installer,
since we'll be installing GNOME anyway.

Make sure to set up full disk encryption, and update the `fileSystems` options for the disks that are on your machine,
and `hardware-configuration.nix` as needed.

Simply run `NIX_CONFIG="experimental-features = nix-command flakes" sudo nixos-rebuild switch ~/git/dotfiles/.#edgerunner`
(replacing `.#edgerunner` with your desired flake output target). After the first time, you can just run `nh os switch`.
This uses [nix-community/nh](https://github.com/nix-community/nh).

## macOS

On macOS, first install [Lix](https://lix.systems/install/#on-any-other-linuxmacos-system), and when asked,
make sure to choose yes to enable flakes.
Then, for the first install, you'll need to run `nix-darwin` as `sudo` via `nix run`:

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake $HOME/git/dotfiles/.#aldecaldo
```

After that, you can just run `nh darwin switch`.

## Managing Dotfiles

Dotfiles are managed via [Nix](https://nixos.org/), using `flake.nix` and [`home-manager`](https://github.com/nix-community/home-manager).
On NixOS, the `home-manager` configuration is managed as a NixOS module, so simply rebuilding your NixOS config also applies the new
`home-manager` config. On macOS, the same behavior is achieved via [nix-darwin](https://github.com/nix-darwin/nix-darwin).

On both, I use `nh`, which simplifies the CLI as well as automatically managing some things like better cleanup/garbage collection,
as well as build tree visualization via [nix-output-monitor](https://github.com/maralorn/nix-output-monitor).

- NixOS: `nh os switch`
- macOS: `nh darwin switch`
