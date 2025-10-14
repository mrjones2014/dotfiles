return {
  {
    'SmiteshP/nvim-navic',
    init = function()
      require('my.utils.lsp').on_attach(function(client, bufnr)
        if not client.server_capabilities.documentSymbolProvider then
          return
        end

        if
          (
            vim.bo[bufnr].filetype == 'typescript'
            or vim.bo[bufnr].filetype == 'typescriptreact'
            or vim.bo[bufnr].filetype == 'javascript'
            or vim.bo[bufnr].filetype == 'javascriptreact'
          ) and client.name == 'graphql'
        then
          -- prefer attaching to ts_ls than graphql for typescript and javascript files
          return
        end

        require('nvim-navic').attach(client, bufnr)
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
            cyan = colors.cyan,
            yellow = colors.terminal.yellow_bright,
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
          sl.Tabs,
          sl.Mode,
          sl.Branch,
          sl.IsTmpFile,
          shared.FileIcon('surface0'),
          sl.FilePath,
          shared.Align,
          sl.UnsavedChanges,
          shared.Align,
          sl.RecordingMacro,
          sl.CopilotStatus,
          sl.SpellCheckToggle,
          sl.LspFormatToggle,
        },
        winbar = { ---@diagnostic disable-line:missing-fields
          shared.FileIcon('base'),
          wb.UniqueFilename,
          wb.Diagnostics,
          shared.Trunc,
          wb.Navic,
          shared.Align,
          wb.FilePosition,
        },
      })
    end,
  },
}
