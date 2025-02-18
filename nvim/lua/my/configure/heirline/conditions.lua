local M = {}

function M.should_show_filename(bufname)
  local bt = vim.api.nvim_get_option_value('buftype', { buf = 0 })
  local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  return (not bt or bt == '')
    and ft ~= 'nofile'
    and ft ~= 'Trouble'
    and ft ~= 'snacks_picker_input'
    and ft ~= 'help'
    and bufname
    and bufname ~= ''
end

function M.is_floating_window(win_id)
  win_id = win_id or 0
  local win_cfg = vim.api.nvim_win_get_config(win_id)
  return win_cfg and (win_cfg.relative ~= '' or not win_cfg.relative)
end

return M
