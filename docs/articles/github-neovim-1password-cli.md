<div style="font-size: 10px;">

Originally published at <https://blog.1password.com/1password-neovim/>

</div>

# Bringing my GitHub workflow into Neovim using 1Password CLI

As a full-time Neovim user, the more things I can do without leaving my terminal, the more efficient my development workflow can be. However, command line tools
that require authentication can present a potentially big problem: They all have their own ways of storing credentials, often using plaintext files stored on disk.
We can mitigate this and keep everything safe and secure in 1Password using [1Password CLI](https://developer.1password.com/docs/cli/)!

## What is Neovim?

[Neovim](https://neovim.io/) is a flexible text editor that runs in a terminal. It is a modal editor, which means there are several "modes" that are optimized for
different types of interactions with the interface. For example, there’s Insert mode for typing text, Visual mode for selecting text, Normal mode for navigating
around and manipulating text, and Command mode for running commands.

While very basic with the default configuration, it can also be highly customized and endowed with all the same magic as a full-fledged IDE, while still maintaining
the speed and efficiency that comes with learning to use a modal editor effectively.

## Getting started with Neovim

If you're starting a Neovim configuration from scratch, I highly recommend using Lua (as opposed to [Vimscript](https://learnxinyminutes.com/docs/vimscript/)\).
If you're already familiar with Neovim, feel free to [skip ahead](#github-meet-neovim). To learn the basics of using Neovim, open Neovim by running the `nvim`
command, then type `:Tutor<Enter>` to run the tutorial.

To kickstart your Neovim configuration, we'll start with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), an open-source configuration file that you
can use to build your own configurations and personalizations. `kickstart.nvim` does several things for us. It sets some of the most common options to more sensible
defaults, and installs [packer.nvim](https://github.com/wbthomason/packer.nvim), a popular plugin manager for Neovim.

It also installs some popular plugins via `packer.nvim`, including:

- Plugins to set up Neovim's built-in [LSP client](https://neovim.io/doc/user/lsp.html), which enables rich language features such as "go to definition", "go to implementation", "find references", autocompletion, and other IDE-like features.
- Plugins that provide rich `git` integration.
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), a powerful and extensible fuzzy-finder plugin.
- Some UI plugins to make everything look cohesive and pretty.

To use this as your starting configuration, simply download [the init.lua file](https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua) and place it at
`~/.config/nvim/init.lua`. Then, from a terminal, run `nvim` and wait for plugins to install before restarting Neovim by typing `:q<Enter>` to exit, then `nvim`
to open it again.

## GitHub, meet Neovim

Recently I found a Neovim plugin called [octo.nvim](https://github.com/pwntester/octo.nvim) that provides a nice interface for searching issues, applying labels,
and even adding comments and Pull Request reviews, all without ever leaving Neovim. This plugin uses the [GitHub CLI](https://cli.github.com/) to interact with
GitHub via the GraphQL API.

Unfortunately, it only seemed to support authentication using the GitHub CLI's built-in credential manager (the `gh auth login` command). However, I already had
a GitHub token in 1Password and I didn't want to export that to another place I'd have to remember if I ever needed to reset my token. I set off on a mission to
make `octo.nvim` and the GitHub CLI integrate with 1Password CLI to retrieve my token directly from 1Password.

## The beauty of open source

To make that possible, I needed to make a small change to `octo.nvim` that would allow the plugin to dynamically request the token only when needed. I made
[a small Pull Request](https://github.com/pwntester/octo.nvim/pull/346) which added a configuration option called `gh_env` (short for "GitHub environment") which
would allow the user to pass a set of environment variables, or a function that returns a set of environment variables, that would be used when running GitHub CLI commands.

This Pull Request was merged quickly, which then allowed me to easily integrate `octo.nvim` with 1Password CLI using my own plugin, [op.nvim](https://github.com/mrjones2014/op.nvim),
a 1Password plugin for Neovim. The `op.nvim` plugin provides some first-class editor features for 1Password, like a [secure notes editor](https://github.com/mrjones2014/op.nvim#secure-notes-editor)
and a sidebar for favorited items and secure notes.

But what's particularly interesting in this case is the [native Lua API bindings to 1Password CLI](https://github.com/mrjones2014/op.nvim#api). This means you can
run 1Password CLI commands in a way that just feels like writing Lua code. For example, `require('op.api').item.get({ 'GitHub', '--format', 'json' })` will retrieve
an item from 1Password called "GitHub" in JSON format.

## Let's get started

If you haven't already, install [1Password CLI](https://developer.1password.com/docs/cli/) and the [GitHub CLI](https://cli.github.com/). You may also want to check
out the [1Password Shell Plugin for the GitHub CLI](https://developer.1password.com/docs/cli/shell-plugins/github/)!

Before we can interact with GitHub via the GitHub CLI in Neovim, we first have to create an access token to use for GitHub authentication.
Open the [GitHub developer settings page](https://github.com/settings/tokens) and create a new "classic" token. In the "Note" field, write "Neovim" (or anything that will remind you
what it is used for) and grant it the `repo`, `read:org`, and `write:org` permission scopes.

![Permission settings while creating a new GitHub access token](https://user-images.githubusercontent.com/8648891/245626100-4d0a5e61-4485-4012-a65f-88cfb0b65904.png)

Then generate the token and save it to your GitHub login item in 1Password, under a field called "token".

![Example 1Password item storing a GitHub access token](https://user-images.githubusercontent.com/8648891/245626124-640cbfa8-1491-441b-8002-c6500ab05e24.png)

## Making the magic happen 🪄

To install the required Neovim plugins, open the `~/.config/nvim/init.lua` file you created earlier. Near the top, where you see the other `use` statements, add
the following snippet of Lua code, which will install `octo.nvim` and `op.nvim`:

```lua
use({
	"pwntester/octo.nvim",
	requires = {
		-- 1Password plugin for Neovim
		"mrjones2014/op.nvim",
		-- another plugin to make the UI a bit nicer
		"stevearc/dressing.nvim",
	},
})
```

Next, jump to near the bottom of the file, add a new section for the configuration of the `octo.nvim` plugin, and add the following code:

```lua
require("octo").setup({
	gh_env = function()
		-- the 'op.api' module provides the same interface as the CLI
		-- each subcommand accepts a list of arguments
		-- and returns a list of output lines.
		-- use it to retrieve the GitHub access token from 1Password
		local github_token = require("op.api").item.get({ "GitHub", "--fields", "token" })[1]
		if not github_token or not vim.startswith(github_token, "ghp_") then
			error("Failed to get GitHub token.")
		end

		-- the values in this table will be provided to the
		-- GitHub CLI as environment variables when invoked,
		-- with the table keys (e.g. GITHUB_TOKEN) being the
		-- environment variable name, and the values (e.g. github_token)
		-- being the variable value
		return { GITHUB_TOKEN = github_token }
	end,
})
```

Then, close and reopen Neovim, and run the `:PackerSync<Enter>` command to install the new plugins and apply configuration changes.

With this configuration, the `octo.nvim` plugin will automatically request authorization via 1Password CLI, and if enabled, even use biometric authentication via
1Password! To try it out, open Neovim from a GitHub repository directory and run `:Octo issue list` to list issues in the GitHub repository.

Enjoy using in Neovim! If you run into any snags or just want to share your experience, join us in the
[1Password Developer Slack](https://join.slack.com/t/1password-devs/shared_invite/zt-1halo11ps-6o9pEv96xZ3LtX_VE0fJQA).
