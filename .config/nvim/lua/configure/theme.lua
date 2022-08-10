return {
  'olimorris/onedarkpro.nvim',
  config = function()
    local onedarkpro = require('onedarkpro')
    local utils = require('onedarkpro.utils')
    onedarkpro.setup({
      dark_theme = 'onedark_vivid',
      colors = {
        bg = '#000000',
        color_column = utils.lighten('#000000', 0.25, '#313131'),
        telescope_prompt = utils.lighten('#000000', 0.01, '#101010'),
        telescope_results = '#000000',
      },
      hlgroups = {
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
        native_lsp = true,
        treesitter = true,
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
