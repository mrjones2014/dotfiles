local Methods = vim.lsp.protocol.Methods

local M = {}

local formatting_enabled = true

---Set up a callback to run on LSP attach
---@param callback fun(client:vim.lsp.Client,bufnr:number)
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

  local function vsplit_then(callback)
    return function()
      vim.cmd.vsp()
      callback()
    end
  end

  require('which-key').add({
    {
      'gh',
      function()
        -- I have diagnostics float on CursorHold,
        -- disable that if I've manually shown the hover window
        -- see require('my.utils.lsp').on_attach_default
        vim.cmd.set('eventignore+=CursorHold')
        vim.lsp.buf.hover()
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'WinEnter', 'BufEnter' }, {
          command = ':set eventignore-=CursorHold',
          pattern = '<buffer>',
          once = true,
        })
      end,
      desc = 'Show LSP hover menu',
      buffer = bufnr,
    },
    { 'gs', vim.lsp.buf.signature_help, desc = 'Show signature help', buffer = bufnr },
    { 'gr', vim.lsp.buf.references, desc = 'Find references', buffer = bufnr },
    {
      'gR',
      function()
        require('glance').open('references')
      end,
      desc = 'Peek references',
      buffer = bufnr,
    },
    { 'gd', vim.lsp.buf.definition, desc = 'Go to definition', buffer = bufnr },
    {
      'gD',
      function()
        require('glance').open('definitions')
      end,
      desc = 'Peek definition',
      buffer = bufnr,
    },
    { 'gi', vim.lsp.buf.implementation, desc = 'Go to implementation', buffer = bufnr },
    {
      'gI',
      function()
        require('glance').open('implementations')
      end,
      desc = 'Peek implementation',
      buffer = bufnr,
    },
    { 'gt', vim.lsp.buf.type_definition, desc = 'Go to type definition', buffer = bufnr },
    { '<leader>gd', vsplit_then(vim.lsp.buf.definition), desc = 'Go to definition in new split', buffer = bufnr },
    {
      '<leader>gi',
      vsplit_then(vim.lsp.buf.implementation),
      desc = 'Go to implementation in new split',
      buffer = bufnr,
    },
    {
      '<leader>gt',
      vsplit_then(vim.lsp.buf.type_definition),
      desc = 'Go to type definition in new split',
      buffer = bufnr,
    },
    { '<leader>rn', vim.lsp.buf.rename, desc = 'Rename symbol', buffer = bufnr },
    { 'F', vim.lsp.buf.code_action, desc = 'Show code actions', buffer = bufnr },
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
---@return boolean
function M.has_formatter(buf)
  buf = buf or tonumber(vim.g.actual_curbuf or vim.api.nvim_get_current_buf())

  local formatter = require('my.ftconfig').formatters_by_ft[vim.bo[buf].ft]
  if formatter then
    return #formatter > 0
  end

  -- otherwise just return the LSP server name
  local clients = vim.lsp.get_clients({ bufnr = buf, method = Methods.textDocument_formatting })
  return #clients > 0
end

return M
