local Methods = vim.lsp.protocol.Methods

local M = {}

local formatting_enabled = true

---Set up a callback to run on LSP attach
---@param callback fun(client:table,bufnr:number)
function M.on_attach(callback)
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        callback(client, bufnr)
      end
    end,
  })
end

function M.on_attach_default(client, bufnr)
  -- if current nvim version supports inlay hints, enable them
  if vim.lsp['inlay_hint'] ~= nil and client.supports_method(Methods.textDocument_inlayHint) then
    vim.lsp.inlay_hint.enable(true)
  end

  -- Run eslint fixes before writing
  if client.name == 'eslint' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
    })
  end

  vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor', border = 'none' })
    end,
    buffer = bufnr,
  })
end

function M.apply_ui_tweaks()
  -- customize LSP icons
  local icons = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  }

  local icon_map = {
    [vim.diagnostic.severity.ERROR] = icons.Error,
    [vim.diagnostic.severity.WARN] = icons.Warn,
    [vim.diagnostic.severity.INFO] = icons.Info,
    [vim.diagnostic.severity.HINT] = icons.Hint,
  }

  local function diagnostic_format(diagnostic)
    return string.format('%s %s (%s)', icon_map[diagnostic.severity], diagnostic.message, diagnostic.code)
  end

  vim.diagnostic.config({
    virtual_text = {
      format = diagnostic_format,
      prefix = '',
    },
    float = {
      format = diagnostic_format,
    },
    signs = { priority = 100, text = icon_map },
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

function M.is_formatting_enabled()
  return formatting_enabled
end

---@param buf number|nil defaults to 0 (current buffer)
---@return string|nil
function M.get_formatter_name(buf)
  buf = buf or tonumber(vim.g.actual_curbuf or vim.api.nvim_get_current_buf())

  -- if it uses conform.nvim, grab the formatter name
  local formatter = require('my.lsp.filetypes').formatters_by_ft[vim.bo[buf].ft]
  if formatter then
    return type(formatter) == 'table' and table.concat(formatter, ', ') or formatter
  end

  -- otherwise just return the LSP server name
  local clients = vim.lsp.get_clients({ bufnr = buf, method = Methods.textDocument_formatting })
  if #clients > 0 then
    return clients[1].name
  end

  return nil
end

---@param buf number|nil defaults to 0 (current buffer)
---@return boolean
function M.is_formatting_supported(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not formatting_enabled then
    return false
  end

  local clients = vim.lsp.get_clients({ bufnr = buf, method = Methods.textDocument_formatting })
  return #clients > 0
end

return M
