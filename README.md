# Installing on a New System

You can run the following to get these dotfiles installed on your system. It will make a backup of your existing dotfiles.

```sh
curl https://raw.githubusercontent.com/mrjones2014/dotfiles/master/scripts/config-init | bash
```

Then, see [manual setup instructions](./docs/manual-setup.md) to get started.

## Managing Dotfiles

The `fish` config sets up an alias `dots` which is an alias to `git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME`. This means you can `dots add ./path/to/file`
and `dots commit -m "Add some file"` from any directory, and it will be properly tracked in the repo at `~/.dotfiles`.
I wrote an [article describing this method](https://mjones.network/storing-dotfiles-in-a-git-repo).

## Caveats

I use macOS. Some things in this repo won't work on Linux, but a lot of it will. Feel free to modify anything you'd like to support Linux.
It will almost certainly not work on Windows and I have zero interest in supporting Windows in this repo.
[Microsoft Windows itself is malware/spyware](https://www.gnu.org/proprietary/malware-microsoft.html).
