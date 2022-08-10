return {
  'olimorris/onedarkpro.nvim',
  config = function()
    local onedarkpro = require('onedarkpro')
    local utils = require('onedarkpro.utils')
    local gray = utils.lighten('#000000', 0.1, '#1b1b1b')
    onedarkpro.setup({
      dark_theme = 'onedark_vivid',
      colors = {
        bg = '#000000',
        color_column = gray,
        telescope_prompt = utils.lighten('#000000', 0.01, '#101010'),
        telescope_results = '#000000',
      },
      hlgroups = {
        LineNr = gray,
        SignColumn = gray,
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
          fg = '${purple}',
          bg = '${telescope_prompt}',
        },
        TelescopePromptTitle = {
          fg = '${telescope_prompt}',
          bg = '${purple}',
        },

        TelescopePreviewTitle = {
          fg = '${telescope_results}',
          bg = '${green}',
        },
        TelescopeResultsTitle = {
          fg = '${telescope_results}',
          bg = '${telescope_results}',
        },

        TelescopeMatching = { fg = '${purple}' },
        TelescopeNormal = { bg = '${telescope_results}' },
        TelescopeSelection = { bg = '${telescope_prompt}' },
      },
      plugins = {
        all = true,
      },
      options = {
        bold = true,
        italic = true,
        undercurl = true,
        window_unfocussed_color = true,
      },
      styles = {
        comments = 'italic',
      },
    })
    vim.cmd('colorscheme onedarkpro')
  end,
}
