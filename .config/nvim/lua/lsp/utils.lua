local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client)
  vim.api.nvim_add_user_command(
    'Format',
    M.formatDocument,
    { desc = 'Format the document using the formatter configured in null-ls config' }
  )
  vim.cmd([[
    augroup fmt
      autocmd BufWritePre * Format
    augroup END
  ]])

  -- show diagnostics on hover
  vim.cmd('autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor", border="rounded"})')

  -- setup LSP-specific keymaps
  require('keymap').apply_lsp_keymaps()

  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = {
      border = 'single',
    },
    fix_pos = true,
    hint_enable = true,
    hint_prefix = '',
    padding = '',
  })

  -- Disable formatting with other LSPs because we're handling formatting via null-ls
  if client.name ~= 'null-ls' then
    client.resolved_capabilities.document_formatting = false
  end
end

function M.formatDocument()
  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

  vim.lsp.buf.formatting_sync(nil, 1500)
end

return M
