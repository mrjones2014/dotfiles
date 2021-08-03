require('indent_blankline').setup({
  buftype_exclude = {'NvimTree', 'terminal', 'term', 'packer', 'dashboard', 'gitcommit', 'fugitive'},
  filetype_exclude = {'NvimTree', 'terminal', 'term', 'packer', 'dashboard', 'gitcommit', 'fugitive'},
  context_patterns = {'class', 'function', 'method', 'block', 'list_literal', 'selector', '^if', '^table', 'if_statement', 'while', 'for'},
  show_first_indent_level = true,
  show_current_context = true,
})

-- because lazy load indent-blankline so need readd this autocmd
vim.cmd('autocmd CursorMoved * IndentBlanklineRefresh')
