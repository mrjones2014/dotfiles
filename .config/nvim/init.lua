require('my.globals')
require('my.settings')
require('my.plugins')

vim.api.nvim_create_autocmd('UiEnter', {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if #vim.api.nvim_buf_get_name(buf) ~= 0 then
        return
      end
    end
    require('my.startup').show()
  end,
  once = true,
})
