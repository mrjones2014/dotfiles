return {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      -- see also: autocmds.lua
      -- this gets toggled off in insert mode
      -- and back on when leaving insert mode
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 100,
      },
      worktrees = {
        {
          toplevel = vim.env.HOME,
          gitdir = string.format('%s/.dotfiles', vim.env.HOME),
        },
      },
    })
  end,
}
