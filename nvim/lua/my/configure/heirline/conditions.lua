local M = {}

function M.is_markdown_preview()
  return vim.b[tonumber(vim.g.actual_curbuf or 0)].mdpreview_session ~= nil
end

function M.should_show_filename(bufname)
  local bt = vim.api.nvim_buf_get_option(0, 'buftype')
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  return M.is_markdown_preview()
      or (not bt or bt == '')
      and ft ~= 'nofile'
      and ft ~= 'Trouble'
      and ft ~= 'Telescope'
      and ft ~= 'help'
      and bufname
      and bufname ~= ''
      and not vim.startswith(bufname, 'component://')
end

return M
