return {
  'folke/tokyonight.nvim',
  config = function()
    local sidebarColor = '#2a2a28'
    local backgroundColor = '#212222'
    vim.g.tokyonight_style = 'night'
    vim.g.tokyonight_sidebars = { 'packer', 'NvimTree', 'Trouble' }
    vim.g.tokyonight_colors = {
      bg = backgroundColor,
      bg_dark = backgroundColor,
      bg_sidebar = sidebarColor,
      bg_float = sidebarColor,
    }

    vim.cmd('colorscheme tokyonight')
  end,
}
