local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
  -- setup LSP-specific keymaps
  require('legendary').bind_keymaps(require('keymap').lsp_keymaps(bufnr))
  require('legendary').bind_commands(require('commands').lsp_commands(bufnr))
  require('legendary').bind_autocmds(require('autocmds').lsp_autocmds(bufnr))

  if
    vim.bo.filetype == 'javascript'
    or vim.bo.filetype == 'typescript'
    or vim.bo.filetype == 'javascriptreact'
    or vim.bo.filetype == 'typescriptreact'
  then
    require('legendary').bind_command({
      ':OrganizeImports',
      M.organize_imports,
      description = 'Organize imports via tsserver',
    })
  end

  -- Disable formatting with other LSPs because we're handling formatting via null-ls
  if client.name ~= 'null-ls' then
    client.resolved_capabilities.document_formatting = false
  end
end

function M.format_document()
  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

  if not vim.b.format_saving then
    vim.b.format_changedtick = vim.b.changedtick
    vim.lsp.buf.formatting({})
  end
end

return M
