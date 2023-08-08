return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
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
    'windwp/nvim-ts-autotag',
    'JoosepAlviste/nvim-ts-context-commentstring',
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
    vim.filetype.add({
      extension = {
        mdx = 'mdx',
      },
    })
    -- highlight mdx with markdown -- it's close enough. We also do JSX injection via ./after/queries/markdown/injections.scm
    vim.treesitter.language.register('markdown', 'mdx')
    require('nvim-treesitter.configs').setup({
      ensure_installed = require('my.lsp.filetypes').treesitter_parsers(),
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
