# Installing on a New System

You can run the following to get these dotfiles installed on your system. It will make a backup of your existing dotfiles.

```sh
wget https://raw.githubusercontent.com/mrjones2014/dotfiles/master/scripts/config-init | bash
```

## Git Aliases

The git aliases are in a separate file so that my email address doesn't need to be in this repo.
To get the git aliases to work, add the following lines to your `~/.gitconfig`:

```
[include]
  path = ~/.gitconfig.aliases
```
