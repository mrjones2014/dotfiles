return {
  'projekt0n/github-nvim-theme',
  -- after = 'lualine.nvim',
  config = function()
    require('github-theme').setup({
      theme_style = 'dark_default',
      sidebars = {
        'NvimTree',
        'terminal',
        'TelescopePrompt',
        'packer',
        'dashboard',
      },
    })
    vim.cmd('colorscheme github')
  end,
}
