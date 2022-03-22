# Installing on a New System

You can run the following to get these dotfiles installed on your system. It will make a backup of your existing dotfiles.

```sh
curl https://raw.githubusercontent.com/mrjones2014/dotfiles/master/scripts/config-init | bash
```

## Managing Dotfiles

The `fish` config sets up an alias `dots` which is an alias to `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`. This means you can `dots add ./path/to/file`
and `dots commit -m "Add some file"` from any directory, and it will be properly tracked in the repo at `~/.dotfiles`.

## Caveats

I use macOS. Some things in this repo won't work on Linux, but a lot of it will. Feel free to modify anything you'd like to support Linux.

For Hammerspoon to find the config, you'll need to run `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`
after installing Hammerspoon, then restart Hammerspoon.

## Manual Config

### Package Management

You'll need/want to install [Homebrew](https://brew.sh). For Apple Silicon Macs you'll need to run the `brew` install script
as well as `brew` itself through Rosetta until Homebrew is updated to support Apple Silicon natively.
See [here](https://stackoverflow.com/questions/64882584/how-to-run-the-homebrew-installer-under-rosetta-2-on-m1-macbook/64883440) for how to do so.

### Packages

There are some global installations that are required for some of the shell and nvim LSP configuration. The `check-globals.fish` script should output help text
for installing them if they're missing.

### Shell

You'll need to install [Fish Shell](https://github.com/fish-shell/fish-shell) before the shell config will work, since its a Fish config.

## Neovim Config

The Neovim configuration is written in Lua and is using mostly Lua-based plugins, like built-in LSP, Telescope for file finding and live grep,
which means you need Neovim with Lua support. I'm also using the `vim.ui` and `vim.diagnostic` Lua modules. It also uses the new `vim.keymap.set` API
so for now it requires Neovim nightly until Neovim 0.7.0 is released.

## Git Config

In order to keep my email addresses and signing key IDs out of version control, I `includeIf` them from separate configs for work vs. personal
development. Set `user.email` and `user.signingkey` in `~/.config/git/gitconfig.work` and `~/.config/git/gitconfig.personal` (which are not tracked in git).
