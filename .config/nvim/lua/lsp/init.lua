require('lsp.utils.ui-customization')

-- format on save asynchronously, see lsp/utils/init.lua M.format function
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
      vim.cmd('update')
      vim.b.format_saving = false
    end
  end
end

require('lsp.css')
require('lsp.html')
require('lsp.json')
require('lsp.typescript')
require('lsp.lua')
require('lsp.rust')
require('lsp.csharp')
require('lsp.svelte')
require('lsp.null-ls')
