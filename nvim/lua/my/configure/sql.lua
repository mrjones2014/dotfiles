return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    'tpope/vim-dadbod',
    {
      'kristijanhusak/vim-dadbod-completion',
      dependencies = {
        'saghen/blink.cmp',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
          sources = {
            per_filetype = {
              sql = { 'snippets', 'dadbod', 'buffer' },
            },
            providers = {
              dadbod = {
                name = 'Dadbod',
                module = 'vim_dadbod_completion.blink',
                -- boost sql schema suggestions to top
                score_offset = 100,
              },
            },
          },
        },
      },
    },
  },
  cmd = {
    'DB',
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
