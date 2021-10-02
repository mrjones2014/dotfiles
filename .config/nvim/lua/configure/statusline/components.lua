local M = {}

local icons = require('nvim-nonicons')
local modeIcons = {
  ['n'] = icons.get('vim-normal-mode'),
  ['no'] = icons.get('vim-normal-mode'),
  ['nov'] = icons.get('vim-normal-mode'),
  ['noV'] = icons.get('vim-normal-mode'),
  ['no'] = icons.get('vim-normal-mode'),
  ['niI'] = icons.get('vim-normal-mode'),
  ['niR'] = icons.get('vim-normal-mode'),
  ['niV'] = icons.get('vim-normal-mode'),
  ['v'] = icons.get('vim-visual-mode'),
  ['V'] = icons.get('vim-visual-mode'),
  [''] = icons.get('vim-visual-mode'),
  ['s'] = icons.get('vim-select-mode'),
  ['S'] = icons.get('vim-select-mode'),
  [''] = icons.get('vim-select-mode'),
  ['i'] = icons.get('vim-insert-mode'),
  ['ic'] = icons.get('vim-insert-mode'),
  ['ix'] = icons.get('vim-insert-mode'),
  ['R'] = icons.get('vim-replace-mode'),
  ['Rc'] = icons.get('vim-replace-mode'),
  ['Rv'] = icons.get('vim-replace-mode'),
  ['Rx'] = icons.get('vim-replace-mode'),
  ['c'] = icons.get('vim-command-mode'),
  ['cv'] = icons.get('vim-command-mode'),
  ['ce'] = icons.get('vim-command-mode'),
  ['r'] = icons.get('vim-replace-mode'),
  ['rm'] = icons.get('vim-replace-mode'),
  ['r?'] = icons.get('vim-replace-mode'),
  ['!'] = icons.get('terminal'),
  ['t'] = icons.get('terminal'),
}

local function rpad(str, len, char)
  str = tostring(str)
  char = char or ' '
  return string.rep(char, len - #str) .. str
end

local function lpad(str, len, char)
  str = tostring(str)
  char = char or ' '
  return str .. string.rep(char, len - #str)
end

function M.mode()
  local mode = vim.api.nvim_get_mode().mode
  if modeIcons[mode] == nil then
    return mode
  end

  return ' ' .. modeIcons[mode] .. '  '
end

function M.filename(buffnr)
  local name = vim.fn.bufname(buffnr)
  return ' ' .. vim.fn.fnamemodify(name, '%:p') .. ' '
end

function M.filetype(buffnr)
  return ' ' .. vim.api.nvim_buf_get_option(buffnr, 'filetype') .. '  '
end

function M.filetypeIcon(buffnr)
  local fileType = vim.api.nvim_buf_get_option(buffnr, 'filetype')
  return ' ' .. (icons.get(fileType) or icons.get('file')) .. ' '
end

function M.lineCol(_, winid, _, is_floatline)
  if is_floatline then
    winid = 0
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(winid or 0))
  return string.format(' %s:%s ', rpad(row, 3), lpad(col, 2))
end

function M.progress()
  local line_fraction = math.floor(vim.fn.line('.') / vim.fn.line('$') * 100) .. '%%'
  return ' ' .. rpad(line_fraction, 5, ' ') .. ' '
end

function M.branchName()
  local branch = ' '
  require('plenary.job')
    :new({
      command = 'git',
      args = { 'branch', '--show-current' },
      cwd = vim.fn.getcwd(),
      on_stdout = function(_, data)
        branch = data
      end,
    })
    :sync()
  if branch and #branch > 1 then
    return ' ' .. icons.get('git-branch') .. ' ' .. branch .. ' '
  end
  return branch
end

return M
