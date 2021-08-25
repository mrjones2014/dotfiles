return {
  'akinsho/nvim-bufferline.lua',
  event = 'BufLeave', -- when leaving dashboard buffer
  config = function()
    require('bufferline').setup({
      options = {
        max_name_length = 24,
      },
    })
  end,
}
