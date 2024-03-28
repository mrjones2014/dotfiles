return {
  'nvim-pack/nvim-spectre',
  dependencies = {
    { 'grapp-dev/nui-components.nvim', dependencies = { 'MunifTanjim/nui.nvim' } },
  },
  keys = {
    {
      '<C-f>',
      function()
        require('my.configure.spectre.ui').toggle()
      end,
      desc = 'Global Search & Replace',
    },
  },
  opts = {},
}
