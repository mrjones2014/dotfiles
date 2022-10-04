return {
  'olimorris/onedarkpro.nvim',
  config = function()
    local onedarkpro = require('onedarkpro')
    local utils = require('onedarkpro.lib.color')
    onedarkpro.setup({
      dark_theme = 'onedark_dark',
      caching = true,
      colors = {
        telescope_prompt = utils.lighten('#000000', 0.01, '#101010'),
        telescope_results = '#000000',
        comment = onedarkpro.get_colors('onedark_vivid').gray,
      },
      ft_highlights = {
        markdown = {
          TSTitle = { fg = '${red}', style = 'bold' },
          TSPunctSpecial = { fg = '${red}' },
          TSPunctDelimiter = { fg = '${comment}' },
          TSTextReference = { fg = '${blue}' },
          TSURI = { fg = '${comment}' },
          TSLiteral = { fg = '${green}' },
          TSParameter = { fg = '${fg}' },
        },
      },
      highlights = {
        CmdLine = {
          bg = '#272B33',
          fg = '${Normal}',
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
        BufferCurrent = { fg = 'Normal', style = 'bold,italic' },
        BufferCurrentMod = { fg = 'Normal', style = 'bold,italic' },
      },
      plugins = {
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
