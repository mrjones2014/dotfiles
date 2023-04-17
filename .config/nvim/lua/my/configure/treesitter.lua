return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'HiPhish/nvim-ts-rainbow2',
    'windwp/nvim-ts-autotag',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'andymass/vim-matchup',
    {
      'ziontee113/query-secretary',
      config = function()
        require('query-secretary').setup({})
      end,
    },
  },
  event = 'BufRead',
  cmd = { 'TSInstall', 'TSUpdate', 'TSUpdateSync' },
  build = function()
    if #vim.api.nvim_list_uis() == 0 then
      -- update sync if running headless
      vim.cmd.TSUpdateSync()
    else
      -- otherwise update async
      vim.cmd.TSUpdate()
    end
  end,
  init = function()
    vim.g.matchup_matchparen_offscreen = {
      method = 'popup',
    }
  end,
  config = function()
    local rainbow = require('ts-rainbow')
    require('nvim-treesitter.configs').setup({
      ensure_installed = require('my.lsp.filetypes').treesitter_parsers,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        -- not sure why but these don't work correctly
        -- if they're defined in keymaps.lua instead of here
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<S-CR>',
          node_decremental = '<BS>',
        },
      },
      rainbow = {
        enable = true,
        strategy = {
          rainbow.strategy.global,
        },
        query = {
          'rainbow-parens',
          html = 'rainbow-tags',
        },
      },
      autotag = {
        enable = true,
      },
      context_commentstring = {
        enable = true,
      },
      matchup = {
        enable = true,
        include_match_words = true,
      },
    })
  end,
}
