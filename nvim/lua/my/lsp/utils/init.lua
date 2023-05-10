local M = {}

local init_done = false

function M.on_attach(client, bufnr)
  -- setup LSP-specific keymaps
  require('legendary').keymaps(require('my.legendary.keymap').lsp_keymaps(bufnr))
  require('legendary').commands(require('my.legendary.commands').lsp_commands(bufnr, client.name))
  require('legendary').autocmds(require('my.legendary.autocmds').lsp_autocmds(bufnr, client.name))

  if not init_done then
    init_done = true
    M.setup_async_formatting()
    M.apply_ui_tweaks()
  end

  -- Disable formatting with other LSPs because we're handling formatting via null-ls
  if client.name ~= 'null-ls' then
    client.server_capabilities.documentFormattingProvider = false
  end
end

function M.setup_async_formatting()
  -- format on save asynchronously, see M.format_document
  vim.lsp.handlers['textDocument/formatting'] = function(err, result, ctx)
    if err ~= nil then
      vim.api.nvim_err_write(err)
      return
    end

    if result == nil then
      return
    end

    if
      vim.api.nvim_buf_get_var(ctx.bufnr, 'format_changedtick') == vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick')
    then
      local view = vim.fn.winsaveview()
      vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
      vim.fn.winrestview(view)
      if ctx.bufnr == vim.api.nvim_get_current_buf() then
        vim.b.format_saving = true
        vim.cmd.update()
        vim.b.format_saving = false
      end
    end
  end
end

function M.apply_ui_tweaks()
  -- customize LSP icons
  local icons = require('my.lsp.icons')
  for type, icon in pairs(icons) do
    local highlight = 'DiagnosticSign' .. type
    local legacy_highlight = 'DiagnosticSign' .. type
    vim.fn.sign_define(highlight, { text = icon, texthl = highlight, numhl = highlight })
    vim.fn.sign_define(legacy_highlight, { text = icon, texthl = legacy_highlight, numhl = legacy_highlight })
  end

  local icon_map = {
    [vim.diagnostic.severity.ERROR] = icons.Error,
    [vim.diagnostic.severity.WARN] = icons.Warn,
    [vim.diagnostic.severity.INFO] = icons.Info,
    [vim.diagnostic.severity.HINT] = icons.Hint,
  }

  local function diagnostic_format(diagnostic)
    if diagnostic.source == 'eslint' or diagnostic.source == 'eslint_d' then
      return string.format('%s %s (%s)', icon_map[diagnostic.severity], diagnostic.message, diagnostic.code)
    end

    return string.format('%s %s', icon_map[diagnostic.severity], diagnostic.message)
  end

  vim.diagnostic.config({
    virtual_text = {
      format = diagnostic_format,
      prefix = '',
    },
    float = {
      format = diagnostic_format,
    },
    signs = { priority = 1000000 },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- enable virtual text diagnostics for Neotest only
  vim.diagnostic.config({ virtual_text = true }, vim.api.nvim_create_namespace('neotest'))
end

function M.is_formatting_supported()
  local clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
  for _, client in ipairs(clients) do
    if client.supports_method('textDocument/formatting') then
      return true
    end
  end

  return false
end

function M.format_document()
  if not M.is_formatting_supported() then
    return
  end

  if not vim.b.format_saving then
    vim.b.format_changedtick = vim.b.changedtick
    vim.lsp.buf.format({ async = true })
  end
end

return M
