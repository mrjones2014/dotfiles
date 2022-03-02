local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
  -- setup LSP-specific keymaps
  require('legendary').bind_keymaps(require('keymap').get_lsp_keymaps(bufnr))
  require('legendary.bindings').bind_command({
    ':Format',
    M.format_document,
    description = 'Format the current document with LSP',
  })
  require('legendary').bind_autocmds(require('autocmds').lsp_autocmds)

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

  -- format on save asynchronously
  vim.lsp.handlers['textDocument/formatting'] = function(err, result, ctx)
    if err ~= nil then
      vim.api.nvim_err_write(err)
      return
    end

    if result == nil then
      return
    end

    if
      vim.api.nvim_buf_get_var(ctx.bufnr, 'format_changedtick')
        == vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick')
      or vim.api.nvim_buf_get_var(ctx.bufnr, 'format_changedtick')
        == vim.api.nvim_buf_get_var(ctx.bufnr, 'changedtick') - 1
    then
      local view = vim.fn.winsaveview()
      vim.lsp.util.apply_text_edits(result, ctx.bufnr, 'utf-16')
      vim.fn.winrestview(view)
      if ctx.bufnr == vim.api.nvim_get_current_buf() then
        vim.b.format_saving = true
        vim.cmd('update')
        vim.b.format_saving = false
      end
    end
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

function M.organize_imports()
  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

  local ft = vim.bo.filetype
  if ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact' then
    local params = {
      command = '_typescript.organizeImports',
      arguments = { vim.api.nvim_buf_get_name(0) },
      title = '',
    }
    vim.lsp.buf_request_sync(vim.api.nvim_get_current_buf(), 'workspace/executeCommand', params, 1500)
  end
end

return M
