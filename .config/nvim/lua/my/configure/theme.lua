return {
  'olimorris/onedarkpro.nvim',
  config = function()
    local onedarkpro = require('onedarkpro')
    local utils = require('onedarkpro.lib.color')
    local dark_gray = utils.lighten('#000000', 0.01, '#101010')
    local normal_fg = '#abb2bf'
    local buffer_inactive = '#434852'
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
        CmdLine = {
          bg = dark_gray,
          fg = normal_fg,
        },
        CmdLineBorder = {
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
        BufferCurrent = { fg = normal_fg, style = 'bold,italic' },
        BufferCurrentMod = { fg = normal_fg, style = 'bold,italic' },
        BufferInactiveSign = { fg = buffer_inactive },
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
