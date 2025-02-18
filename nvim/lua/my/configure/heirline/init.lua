return {
  {
    'SmiteshP/nvim-navic',
    init = function()
      require('my.utils.lsp').on_attach(function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
      end)
    end,
    config = function()
      require('nvim-navic').setup({
        highlight = true,
        separator = '  ',
      })
    end,
  },
  {
    'rebelot/heirline.nvim',
    lazy = false,
    config = function()
      local shared = require('my.configure.heirline.shared')
      local sl = require('my.configure.heirline.statusline')
      local wb = require('my.configure.heirline.winbar')

      local colors = require('tokyonight.colors').setup()
      require('heirline').setup({
        opts = {
          colors = {
            black = colors.bg_dark,
            gray = colors.dark5,
            green = colors.green,
            blue = colors.blue,
            base = colors.bg,
            surface0 = colors.fg_gutter,
            surface1 = colors.dark3,
            surface2 = colors.blue7,
          },
          disable_winbar_cb = function()
            local conditions = require('my.configure.heirline.conditions')
            return conditions.is_floating_window() or not conditions.should_show_filename(vim.api.nvim_buf_get_name(0))
          end,
        },
        statusline = { ---@diagnostic disable-line:missing-fields
          sl.Mode,
          sl.Branch,
          shared.FileIcon('surface0'),
          sl.FilePath,
          sl.Align,
          sl.UnsavedChanges,
          sl.Align,
          sl.RecordingMacro,
          sl.SpellCheckToggle,
          sl.LspFormatToggle,
          sl.LazyStats,
          sl.OnePassword,
          shared.Diagnostics(false),
        },
        winbar = { ---@diagnostic disable-line:missing-fields
          shared.FileIcon('base'),
          wb.UniqueFilename,
          wb.Diagnostics,
          shared.Trunc,
          wb.Navic,
        },
      })
    end,
  },
}
