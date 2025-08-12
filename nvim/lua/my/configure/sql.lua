return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- the default built-in omnicompletion keybinds
    -- are broken with dadbod-ui
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'sql',
      callback = function()
        vim.keymap.del('i', '<left>', { buffer = true })
        vim.keymap.del('i', '<right>', { buffer = true })
      end,
    })
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
