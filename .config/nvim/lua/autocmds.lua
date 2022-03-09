local M = {}

function M.default_autocmds()
  return {
    {
      'BufReadPost',
      [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif]],
    },
    {
      name = 'JsonOptions',
      {
        'FileType',
        ':setlocal conceallevel=0',
        opts = { pattern = 'json' },
      },
    },
    {
      name = 'MarkdownOptions',
      {
        'FileType',
        ':setlocal wrap linebreak',
        opts = { pattern = 'markdown' },
      },
    },
    {
      name = 'JsoncFiletypeDetection',
      {
        { 'BufRead', 'BufNewFile' },
        ':set filetype=jsonc',
        opts = {
          pattern = { '*.jsonc', 'tsconfig*.json' },
        },
      },
    },
  }
end

function M.lsp_autocmds()
  return {
    {
      name = 'LspOnAttachAutocmds',
      clear = true,
      {
        'BufWritePost',
        require('lsp.utils').format_document,
      },
      {
        'CursorHold',
        function()
          vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor', border = 'rounded' })
        end,
      },
    },
  }
end

return M
