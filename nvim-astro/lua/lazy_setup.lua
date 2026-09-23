require('lazy').setup({
  {
    'AstroNvim/AstroNvim',
    version = '^6',
    import = 'astronvim.plugins',
    opts = {
      -- must be set here, before lazy.nvim is set up
      mapleader = ' ',
      maplocalleader = ';',
      icons_enabled = true,
      pin_plugins = nil,
      update_notifications = true,
    },
  },
  { import = 'community' },
  { import = 'plugins' },
} --[[@as LazySpec]], {
  -- local checkouts of my own plugins take priority over the GitHub copy
  dev = { path = '~/git', fallback = true },
  install = { colorscheme = { 'tokyonight', 'astrotheme', 'habamax' } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'zipPlugin',
      },
    },
  },
} --[[@as LazyConfig]])
