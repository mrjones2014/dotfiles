local M = {}

local init_done = false

local formatting_enabled = true

function M.on_attach(client)
  if not init_done then
    init_done = true
    M.setup_async_formatting()
    M.apply_ui_tweaks()
  end

  -- if current nvim version supports inlay hints, enable them
  if vim.lsp.buf['inlay_hint'] ~= nil and client.supports_method('textDocument/inlayHint') then
    vim.lsp.buf.inlay_hint(0, true)
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

function M.toggle_formatting_enabled(enable)
  if enable == nil then
    enable = not formatting_enabled
  end
  if enable then
    formatting_enabled = true
    vim.notify('Enabling LSP formatting...', vim.log.levels.INFO)
  else
    formatting_enabled = false
    vim.notify('Disabling LSP formatting...', vim.log.levels.INFO)
  end
end

function M.get_formatter_name()
  local clients = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })
  for _, client in ipairs(clients) do
    if client.supports_method('textDocument/formatting') then
      if client.name == 'null-ls' then
        local sources = require('null-ls.sources').get_available(vim.bo[tonumber(vim.g.actual_curbuf or 0)].filetype)
        for _, source in ipairs(sources) do
          if source.methods.NULL_LS_FORMATTING then
            return source.name
          end
        end
      end
    end
  end
end

function M.is_formatting_supported()
  if not formatting_enabled then
    return false
  end

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
