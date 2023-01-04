return {
  'olimorris/onedarkpro.nvim',
  lazy = false,
  config = function()
    local onedarkpro = require('onedarkpro')
    onedarkpro.setup({
      log_level = 'debug',
      caching = true,
      colors = {
        dark_gray = '#1A1A1A',
        darker_gray = '#141414',
        darkest_gray = '#080808',
        color_column = '#181919',
        -- glance.nvim
        GlancePreviewNormal = "require('onedarkpro.helpers').darken('bg', 6, 'onedark')",
        GlancePreviewLineNr = "require('onedarkpro.helpers').darken('bg', 6, 'onedark')",
        GlancePreviewSignColumn = "require('onedarkpro.helpers').darken('bg', 6, 'onedark')",
        GlancePreviewCursorLine = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
      },
      highlights = {
        CmpItemMenu = { bg = '${dark_gray}' },
        CmdLine = {
          bg = '${dark_gray}',
          fg = '${fg}',
        },
        CmdLineBorder = {
          bg = '${dark_gray}',
          fg = '${dark_gray}',
        },
        LspFloat = {
          bg = '${darker_gray}',
        },
        LspFloatBorder = {
          bg = '${darker_gray}',
          fg = '${darker_gray}',
        },
        Search = {
          fg = '${black}',
          bg = '${highlight}',
        },
        TelescopeBorder = {
          fg = '${darkest_gray}',
          bg = '${darkest_gray}',
        },
        TelescopePromptBorder = {
          fg = '${darker_gray}',
          bg = '${darker_gray}',
        },
        TelescopePromptCounter = { fg = '${fg}' },
        TelescopePromptNormal = { fg = '${fg}', bg = '${darker_gray}' },
        TelescopePromptPrefix = {
          fg = '${green}',
          bg = '${darker_gray}',
        },
        TelescopePromptTitle = {
          fg = '${darker_gray}',
          bg = '${green}',
        },

        TelescopePreviewTitle = {
          fg = '${darkest_gray}',
          bg = '${green}',
        },
        TelescopeResultsTitle = {
          fg = '${darkest_gray}',
          bg = '${darkest_gray}',
        },

        TelescopeMatching = { fg = '${green}' },
        TelescopeNormal = { bg = '${darkest_gray}' },
        TelescopeSelection = { bg = '${darker_gray}' },

        -- barbar.nvim
        BufferCurrent = { fg = '${fg}', style = 'bold,italic' },
        BufferCurrentMod = { fg = '${fg}', style = 'bold,italic' },
        BufferInactiveSign = { fg = '${darkest_gray}' },

        -- mini.trailspace
        MiniTrailspace = { bg = '${red}' },

        WinBar = { bg = '${darker_gray}' },
        WinBarNC = { bg = '${bg_statusline}' },

        -- glance.nvim
        GlancePreviewNormal = { bg = '${GlancePreviewNormal}' },
        GlancePreviewLineNr = { bg = '${GlancePreviewLineNr}' },
        GlancePreviewCursorLine = { bg = '${GlancePreviewCursorLine}' },
        GlancePreviewSignColumn = { bg = '${GlancePreviewSignColumn}' },
      },
      plugins = {
        all = false,
        gitsigns = true,
        indentline = true,
        neotest = true,
        nvim_cmp = true,
        native_lsp = true,
        nvim_tree = true,
        nvim_ts_rainbow = true,
        op_nvim = true,
        trouble = true,
        leap = true,
        treesitter = true,
        telescope = true,
      },
      options = {
        bold = true,
        italic = true,
        undercurl = true,
        highlight_inactive_windows = true,
      },
      styles = {
        comments = 'italic',
        keywords = 'italic',
      },
    })
    vim.cmd.colorscheme('onedark_dark')
  end,
}
