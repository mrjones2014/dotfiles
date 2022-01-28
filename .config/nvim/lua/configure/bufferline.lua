return {
  'akinsho/nvim-bufferline.lua',
  requires = { 'famiu/bufdelete.nvim' },
  config = function()
    require('bufferline').setup({
      options = {
        max_name_length = 24,
        close_command = 'Bdelete %d',
      },
    })
  end,
}
