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

function M.is_floating_window(win_id)
  win_id = win_id or 0
  local win_cfg = vim.api.nvim_win_get_config(win_id)
  return win_cfg and (win_cfg.relative ~= '' or not win_cfg.relative)
end

return M
