return {
  'akinsho/nvim-bufferline.lua',
  config = function()
    require('bufferline').setup({
      options = {
        max_name_length = 24,
      },
    })
  end,
}
