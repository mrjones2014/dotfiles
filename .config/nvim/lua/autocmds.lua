local M = {}

M.default_autocmds = {
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
    name = 'TerminalBuffers',
    {
      'TermOpen',
      function()
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.cmd('startinsert')
      end,
    },
    {
      'TermClose',
      ':Bdelete',
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

M.lsp_autocmds = {
  {
    name = 'LspOnAttachAutocmds',
    clear = true,
    {
      'BufWritePre',
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

return M
