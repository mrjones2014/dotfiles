return {
  {
    'SmiteshP/nvim-navic',
    init = function()
      LSP.on_attach(function(client, bufnr)
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
      local sc = require('my.configure.heirline.statuscolumn')

      require('heirline').setup({
        opts = {
          colors = require('onedarkpro.helpers').get_colors(),
          disable_winbar_cb = function()
            return not require('my.configure.heirline.conditions').should_show_filename(vim.api.nvim_buf_get_name(0))
          end,
        },
        statusline = {
          sl.Mode,
          sl.Branch,
          shared.FileIcon('bg_statusline'),
          sl.FilePath,
          sl.Align,
          sl.UnsavedChanges,
          sl.Align,
          sl.LspFormatToggle,
          sl.LazyStats,
          sl.OnePassword,
          shared.Diagnostics(false),
        },
        winbar = {
          shared.FileIcon('black'),
          wb.UniqueFilename,
          wb.Diagnostics,
          wb.Navic,
        },
        statuscolumn = {
          sc.DiagnosticSign,
          sc.Align,
          sc.LineNumAndGitIndicator,
        },
      })
    end,
  },
}
