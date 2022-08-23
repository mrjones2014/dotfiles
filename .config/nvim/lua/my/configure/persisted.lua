return {
  'olimorris/persisted.nvim',
  config = function()
    local paths = require('my.paths')
    require('persisted').setup({
      use_git_branch = true,
      autoload = true,
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
