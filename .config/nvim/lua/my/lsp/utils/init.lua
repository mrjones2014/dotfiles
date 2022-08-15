local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
  -- setup LSP-specific keymaps
  require('legendary').bind_keymaps(require('my.keymap').lsp_keymaps(bufnr))
  require('legendary').bind_commands(require('my.commands').lsp_commands(bufnr, client.name))
  require('legendary').bind_autocmds(require('my.autocmds').lsp_autocmds(bufnr, client.name))

  -- Disable formatting with other LSPs because we're handling formatting via null-ls
  if client.name ~= 'null-ls' then
    client.server_capabilities.documentFormattingProvider = false
  end
end

function M.format_document()
  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

  if not vim.b.format_saving then
    vim.b.format_changedtick = vim.b.changedtick
    vim.lsp.buf.format({ async = true })
  end
end

return M
