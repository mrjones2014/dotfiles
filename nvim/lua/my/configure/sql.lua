return {
  'kndndrj/nvim-dbee',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  keys = { { 'BB', desc = 'Run query', mode = { 'v', 'n' } } },
  cmd = 'Sql',
  build = function()
    require('dbee').install()
  end,
  init = function()
    vim.api.nvim_create_user_command('Sql', function()
      require('dbee').open()
    end, {})
  end,
  config = function()
    require('dbee').setup()
  end,
}
