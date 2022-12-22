return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'p00f/nvim-ts-rainbow',
    'windwp/nvim-ts-autotag',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'andymass/vim-matchup',
    'aarondiel/spread.nvim',
    {'ziontee113/query-secretary', config = function()
      require('query-secretary').setup({})
    end},
  },
  event = 'BufRead',
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
        -- keymaps defined in keymaps/init.lua
        keymaps = {},
      },
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 1500,
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
