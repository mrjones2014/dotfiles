# Manual Setup

When installing on a new system, there's a couple setup steps you need to perform manually.

## Installing Packages

Package management is primarily through [Homebrew](https://brew.sh). For Apple silicon (M1 series chipset),
you will need to configure it to run through Rosetta 2 emulation (for now). It will still be able to install
native M1 optimized packages. See [GitHub issue](https://github.com/Homebrew/brew/issues/9173#issuecomment-729987279)
for instructions to install Homebrew and run it through Rosetta 2.

Once you've got that set up, install [Fish shell](https://github.com/fish-shell/fish-shell) via `brew install fish`.
Set Fish as your default shell:

1. Check the path to Fish shell via `which fish`
1. `sudo vi /etc/shells`
1. Add the path from step 1 to the file
1. `:wq` to save and exit
1. `chsh -s /path/to/fish` (replacing `/path/to/fish` with the output from step 1) to change your default shell
1. Log out and back in

Finally, open a terminal and run `check-globals` to see missing CLI tools and how to install them.

## Hammerspoon

After installing [Hammerspoon](https://github.com/Hammerspoon/hammerspoon),
run `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`
in a terminal to make Hammerspoon look in `~/.config/hammerspoon/` for it's config instead
of `~/.hammerspoon/`. Then restart Hammerspoon.

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
