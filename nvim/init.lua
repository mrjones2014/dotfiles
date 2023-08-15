require('my.globals')
require('my.settings')
require('my.plugins')

vim.api.nvim_create_autocmd('UiEnter', {
  callback = function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
      local bufname = vim.api.nvim_buf_get_name(buf)
      if #bufs == 1 and vim.fn.isdirectory(bufname) ~= 0 then
        -- if opened to a directory, cd to the directory and show startup
        vim.cmd.cd(bufname)
        break
      end

      if #bufname ~= 0 then
        return
      end
    end

    require('my.startup').show()
  end,
  once = true,
})
