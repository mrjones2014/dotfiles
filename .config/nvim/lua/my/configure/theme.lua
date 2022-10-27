return {
  'olimorris/onedarkpro.nvim',
  config = function()
    local onedarkpro = require('onedarkpro')
    local colors = require('onedarkpro').get_colors('onedark_dark')
    local dark_gray = '#1A1A1A'
    onedarkpro.setup({
      log_level = 'debug',
      dark_theme = 'onedark_dark',
      caching = true,
      colors = {
        telescope_prompt = dark_gray,
        telescope_results = '#000000',
        comment = onedarkpro.get_colors('onedark_vivid').gray,
      },
      highlights = {
        ['@keyword.operator.lua'] = { fg = '#d55fde', style = 'italic' },
        ['@operator.lua'] = { link = '@keyword.operator.lua' },
        CmpItemMenu = { bg = dark_gray },
        CmdLine = {
          bg = dark_gray,
          fg = colors.fg,
        },
        CmdLineBorder = {
          bg = dark_gray,
          fg = dark_gray,
        },
        LspFloat = {
          bg = dark_gray,
        },
        LspFloatBorder = {
          bg = dark_gray,
          fg = dark_gray,
        },
        LineNr = '${color_column}',
        SignColumn = '${color_column}',
        Search = {
          fg = '${black}',
          bg = '${highlight}',
        },
        TelescopeBorder = {
          fg = '${telescope_results}',
          bg = '${telescope_results}',
        },
        TelescopePromptBorder = {
          fg = '${telescope_prompt}',
          bg = '${telescope_prompt}',
        },
        TelescopePromptCounter = { fg = '${fg}' },
        TelescopePromptNormal = { fg = '${fg}', bg = '${telescope_prompt}' },
        TelescopePromptPrefix = {
          fg = '${green}',
          bg = '${telescope_prompt}',
        },
        TelescopePromptTitle = {
          fg = '${telescope_prompt}',
          bg = '${green}',
        },

        TelescopePreviewTitle = {
          fg = '${telescope_results}',
          bg = '${green}',
        },
        TelescopeResultsTitle = {
          fg = '${telescope_results}',
          bg = '${telescope_results}',
        },

        TelescopeMatching = { fg = '${green}' },
        TelescopeNormal = { bg = '${telescope_results}' },
        TelescopeSelection = { bg = '${telescope_prompt}' },

        -- barbar.nvim
        BufferCurrent = { fg = colors.fg, style = 'bold,italic' },
        BufferCurrentMod = { fg = colors.fg, style = 'bold,italic' },
        BufferInactiveSign = { fg = dark_gray },
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
        packer = true,
        trouble = true,
        leap = true,
        treesitter = true,
      },
      options = {
        bold = true,
        italic = true,
        undercurl = true,
        window_unfocused_color = true,
      },
      styles = {
        comments = 'italic',
        keywords = 'italic',
      },
    })
    vim.cmd.colorscheme('onedarkpro')
  end,
}
