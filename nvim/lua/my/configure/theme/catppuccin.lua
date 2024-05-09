return {
  'catppuccin/nvim',
  enabled = require('my.theme').current_theme == 'catppuccin',
  name = 'catppuccin',
  priority = 1000,
  lazy = false,
  opts = {
    flavour = 'mocha',
    dim_inactive = { enabled = true, percentage = 0.000001 },
    styles = {
      loops = { 'italic' },
      keyword = { 'italic' },
    },
    custom_highlights = function(colors)
      return {
        WinBar = { bg = colors.surface2 },
        TelescopeNormal = { bg = colors.crust },
        TelescopeBorder = { bg = colors.crust, fg = colors.crust },
        TelescopePromptBorder = { bg = colors.base, fg = colors.base },
        TelescopePromptNormal = { bg = colors.base },
        TelescopePromptPrefix = { bg = colors.base },
      }
    end,
    integrations = {
      gitsigns = true,
      indent_blankline = { enabled = true },
      lsp_saga = true,
      markdown = true,
      mini = { enabled = true },
      neotest = true,
      notify = true,
      cmp = true,
      native_lsp = { enabled = true },
      navic = {
        enabled = true,
        -- TODO if I use 'surface2' here I get an error
        custom_bg = '#585b70', ---@diagnostic disable-line: assign-type-mismatch
      },
      semantic_tokens = true,
      treesitter = true,
      rainbow_delimiters = true,
      octo = true,
      telescope = { enabled = true, style = 'nvchad' },
      lsp_trouble = true,
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme('catppuccin')
  end,
}
