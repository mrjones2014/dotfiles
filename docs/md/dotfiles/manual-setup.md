# Manual Setup Steps

When installing on a new machine, there's a few manual setup steps you'll need to do.


## Installing Packages


Package management is primarily through [Homebrew](https://brew.sh). For Apple silicon (M1 series chipset),
you will need to configure it to run through Rosetta 2 emulation (for now). It will still be able to install
native M1 optimized packages. See [GitHub issue](https://github.com/Homebrew/brew/issues/9173%23issuecomment-729987279)
for instructions to install Homebrew and run it through Rosetta 2.

Once you've got that set up, install [Fish shell](https://github.com/fish-shell/fish-shell) via `brew install fish`.
Set Fish as your default shell:

1. Check the path to Fish shell via `which fish`
2. `sudo vi /etc/shells`
3. Add the path from step 1 to the file
4. `:wq` to save and exit
5. `chsh -s /path/to/fish` (replacing `/path/to/fish` with the output from step 1) to change your default shell
6. Log out and back init


Finally, open a terminal and run `check-globals` to see missing CLI tools and how to install them.


## Hammerspoon


After installing [Hammerspoon](https://github.com/Hammerspoon/hammerspoon),
run `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`
in a terminal to make Hammerspoon look in `~/.config/hammerspoon/` for it's config instead
of `~/.hammerspoon/`. Then restart Hammerspoon.


## Configuring Git


In order to keep my email addresses and signing key IDs out of version control, I `includeIf` them from separate
configs for work vs. personal development. Set `user.email` and `user.signingkey` in `~/.config/git/gitconfig.work`
and `~/.config/git/gitconfig.personal` (which are not tracked in git).