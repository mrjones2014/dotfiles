return {
  'nvim-mini/mini.bracketed',
  keys = {
    { '[c', desc = 'Jump to previous comment block' },
    { ']c', desc = 'Jump to next comment block' },
    { '[x', desc = 'Jump to previous conflict marker' },
    { ']x', desc = 'Jump to next conflict marker' },
    { '[d', desc = 'Jump to previous diagnostic' },
    { ']d', desc = 'Jump to next diagnostic' },
    {
      '[e',
      desc = 'Jump to previous error',
      function()
        require('mini.bracketed').diagnostic('backward', { severity = vim.diagnostic.severity.ERROR })
      end,
    },
    {
      ']e',
      desc = 'Jump to next error',
      function()
        require('mini.bracketed').diagnostic('forward', { severity = vim.diagnostic.severity.ERROR })
      end,
    },
    { '[q', desc = 'Jump to previous Quickfix list entry' },
    { ']q', desc = 'Jump to next Quickfix list entry' },
    { '[t', desc = 'Jump to previous Treesitter node' },
    { ']t', desc = 'Jump to next Treesitter node' },
  },
  opts = {},
}
