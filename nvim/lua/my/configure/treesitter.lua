return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    {
      'calops/hmts.nvim',
      version = '*',
      ft = 'nix',
    },
    {
      'hiphish/rainbow-delimiters.nvim',
      config = function()
        local rainbow = require('rainbow-delimiters')
        vim.g.rainbow_delimiters = {
          strategy = {
            [''] = rainbow.strategy['global'],
            vim = rainbow.strategy['local'],
          },
          query = {
            [''] = 'rainbow-delimiters',
            lua = 'rainbow-blocks',
            html = 'rainbow-tags',
          },
          highlight = {
            'RainbowDelimiterRed',
            'RainbowDelimiterYellow',
            'RainbowDelimiterBlue',
            'RainbowDelimiterOrange',
            'RainbowDelimiterGreen',
            'RainbowDelimiterViolet',
            'RainbowDelimiterCyan',
          },
        }
      end,
    },
    {
      'JoosepAlviste/nvim-ts-context-commentstring',
      init = function()
        vim.g.skip_ts_context_commentstring_module = true
      end,
      opts = {},
    },
    'andymass/vim-matchup',
    {
      'ziontee113/query-secretary',
      keys = {
        {
          '<leader>qs',
          function()
            require('query-secretary').query_window_initiate()
          end,
          desc = 'Open Query Secretary',
        },
      },
      opts = {},
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
    vim.filetype.add({
      extension = {
        mdx = 'mdx',
      },
    })
    -- highlight mdx with markdown -- it's close enough. We also do JSX injection via ./after/queries/markdown/injections.scm
    vim.treesitter.language.register('markdown', 'mdx')
    require('nvim-treesitter.configs').setup({ ---@diagnostic disable-line:missing-fields
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
      -- treesitter parser for Swift requires treesitter-cli and only really works on mac
      additional_vim_regex_highlighting = { 'swift' },
      matchup = {
        enable = true,
        include_match_words = true,
      },
    })
  end,
}
