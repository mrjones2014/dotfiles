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
        filter_kind = false,
        attach_mode = 'global',
        keymaps = {
          ['<C-j>'] = false,
          ['<C-k>'] = false,
          ['<C-y>'] = 'actions.up_and_scroll',
          ['<C-e>'] = 'actions.down_and_scroll',
        },
      })
    end,
  },
  config = function()
    require('legendary').command({
      'Tree',
      function()
        local a = require('aerial')
        local tree = require('nvim-tree.api').tree
        if a.is_open() or tree.is_visible() then
          a.close()
          tree.close_in_all_tabs()
          return
        end
        local curwin = vim.api.nvim_get_current_win()
        tree.open({ path = vim.loop.cwd() })
        local orig = vim.opt.splitbelow
        vim.opt.splitbelow = false
        vim.cmd(('%ssp'):format(width))
        vim.cmd('wincmd j')
        vim.opt.splitbelow = orig
        vim.schedule(function()
          a.open_in_win(0, curwin)
          vim.api.nvim_win_set_width(0, width)
          -- put cursor focus back where it was
          vim.api.nvim_set_current_win(curwin)
        end)
      end,
    })
    require('nvim-tree').setup({ view = { side = 'right' } })
  end,
}
