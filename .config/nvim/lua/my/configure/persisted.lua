return {
  'olimorris/persisted.nvim',
  config = function()
    local paths = require('my.paths')
    require('persisted').setup({
      autoload = true,
      on_autoload_no_session = function()
        require('my.startup').show()
      end,
      allowed_dirs = { paths.join(paths.home, 'git'), paths.join(paths.home, '.config') },
      before_save = function()
        pcall(vim.cmd, 'NvimTreeClose')
      end,
      after_source = function()
        pcall(vim.cmd, 'LspRestart')
      end,
    })
  end,
}
