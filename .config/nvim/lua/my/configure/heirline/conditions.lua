local M = {}

function M.should_show_filename(bufname)
  local bt = vim.api.nvim_buf_get_option(0, 'buftype')
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  return (not bt or bt == '')
    and ft ~= 'nofile'
    and ft ~= 'Trouble'
    and ft ~= 'Telescope'
    and ft ~= 'help'
    and bufname
    and bufname ~= ''
    and not vim.startswith(bufname, 'component://')
end

return M
