local Methods = vim.lsp.protocol.Methods

local M = {}

local init_done = false

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
  if not init_done then
    init_done = true
    M.setup_async_formatting()
    M.apply_ui_tweaks()
  end

  -- if current nvim version supports inlay hints, enable them
  if vim.lsp['inlay_hint'] ~= nil and client.supports_method(Methods.textDocument_inlayHint) then
    vim.lsp.inlay_hint.enable(0, true)
  end

  -- Run eslint fixes before writing
  if client.name == 'eslint' then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
    })
  end
end

function M.setup_async_formatting()
  -- format on save asynchronously, see M.format_document
  vim.lsp.handlers[Methods.textDocument_formatting] = function(err, result, ctx)
    if err ~= nil then
      -- efm uses table messages
      if type(err) == 'table' then
        if err.message then
          err = err.message
        else
          err = vim.inspect(err)
        end
      end
      vim.api.nvim_err_write(err --[[@as string]])
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
      if view then
        vim.fn.winrestview(view)
      end
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
    signs = { priority = 100 },
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

---@param buf number|nil defaults to 0 (current buffer)
---@return string|nil
function M.get_formatter_name(buf)
  buf = buf or tonumber(vim.g.actual_curbuf or vim.api.nvim_get_current_buf())

  -- if it uses efm-langserver, grab the formatter name
  local ft_efm_cfg = require('my.lsp.filetypes').config[vim.bo[buf].filetype]
  if ft_efm_cfg and ft_efm_cfg.formatter then
    if type(ft_efm_cfg.formatter) == 'table' then
      return ft_efm_cfg.formatter[1]
    else
      return tostring(ft_efm_cfg.formatter)
    end
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

function M.format_document()
  if not M.is_formatting_supported() then
    return
  end

  if not vim.b.format_saving then
    vim.b.format_changedtick = vim.b.changedtick
    local formats_with_efm = require('my.lsp.filetypes').formats_with_efm()
    vim.lsp.buf.format({
      async = true,
      filter = function(client)
        if formats_with_efm then
          return client.name == 'efm'
        else
          return client.name ~= 'efm'
        end
      end,
    })
  end
end

return M
