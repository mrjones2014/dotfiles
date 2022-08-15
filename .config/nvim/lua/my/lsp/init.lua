require('my.lsp.utils.ui-customization')

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

-- always load null-ls
require('my.lsp.null-ls')

-- lazy-load the rest of the configs with
-- an autocommand that runs only once
-- for each lsp config
local legendary = require('legendary')
for filetype, file_patterns in pairs(require('my.lsp.filetypes').filetype_patterns) do
  legendary.bind_autocmds({
    'BufReadPre',
    function()
      require('my.lsp.' .. filetype)
      local snippets = require('my.lsp.snippets')[filetype]
      if snippets then
        snippets()
      end
    end,
    opts = {
      pattern = file_patterns,
      once = true,
    },
  })
end
