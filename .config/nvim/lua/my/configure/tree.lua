local width = 35

return {
  'nvim-tree/nvim-tree.lua',
  cmd = 'Tree',
  dependencies = {
    'stevearc/aerial.nvim',
    config = function()
      require('aerial').setup({
        layout = {
          max_width = { width },
          min_width = { width },
          placement = 'edge',
        },
        keymaps = {
          ['<C-j>'] = false,
          ['<C-k>'] = false,
          ['<C-y>'] = 'actions.up_and_scroll',
          ['<C-e>'] = 'actions.down_and_scroll',
        }
      })
    end,
  },
  config = function()
    require('legendary').command({
      'Tree',
      function()
        local a = require('aerial')
        local tree = require('nvim-tree.api').tree
        a.open({ focus = true, direction = 'right' })
        local orig = vim.opt.splitbelow
        vim.opt.splitbelow = false
        vim.cmd(('%ssp'):format(width))
        vim.opt.splitbelow = orig
        tree.open({current_window = true, path = vim.loop.cwd() })
        vim.schedule(function()
          vim.api.nvim_win_set_width(0, width)
        end)
      end
    })
    require('nvim-tree').setup()
  end
}
