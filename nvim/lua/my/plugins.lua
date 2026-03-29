vim.pack.add({ 'https://github.com/folke/lazy.nvim.git' })
require('lazy').setup('my.configure', {
  defaults = {
    lazy = true,
  },
  dev = { path = '~/git', fallback = true },
  install = { colorscheme = { vim.env.COLORSCHEME or 'tokyonight', 'habamax' } },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'gzip',
        'zip',
        'zipPlugin',
        'tar',
        'tarPlugin',
        'getscript',
        'getscriptPlugin',
        'vimball',
        'vimballPlugin',
        '2html_plugin',
        'logipat',
        'rrhelper',
        'spellfile_plugin',
        'matchit',
      },
    },
  },
})
