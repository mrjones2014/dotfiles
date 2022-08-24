local M = {}

local function longest_line(strs)
  local longest = 0
  for _, str in pairs(strs) do
    local len = vim.fn.strdisplaywidth(str)
    if len > longest then
      longest = len
    end
  end
  return longest
end

local function center(strs)
  local result = {}
  local win_width = vim.api.nvim_win_get_width(0)
  local max_len = longest_line(strs)
  local space_left = bit.arshift(win_width - max_len, 1)
  for _, str in pairs(strs) do
    table.insert(result, string.rep(' ', space_left + ((max_len - vim.fn.strdisplaywidth(str)) / 2)) .. str)
  end
  return result
end

local header = center({
  require('my.paths').relative_cwd(),
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
  ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
  ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
  ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
  ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
  ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
})

for _ = 1, vim.o.lines - #header, 1 do
  table.insert(header, '')
end

function M.show()
  local buf_id = vim.api.nvim_get_current_buf()
  vim.g.startscreen_buf_id = buf_id
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_buf_set_option(buf_id, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf_id, 'filetype', 'nofile')
  vim.api.nvim_win_set_option(win_id, 'number', false)
  vim.api.nvim_buf_set_lines(buf_id, 0, #header, false, header)
  vim.api.nvim_buf_set_option(buf_id, 'modifiable', false)
  for i = 0, #header, 1 do
    vim.api.nvim_buf_add_highlight(buf_id, 0, 'LspDiagnosticsDefaultInformation', i, 0, -1)
  end

  local augroup = vim.api.nvim_create_augroup('StartScreen', { clear = true })

  -- close the startup buffer when we go anywhere else
  vim.schedule(function()
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        if vim.api.nvim_get_current_win() ~= win_id then
          return
        end

        vim.api.nvim_buf_delete(buf_id, { force = true })
        vim.api.nvim_win_set_option(0, 'number', true)
        vim.api.nvim_del_augroup_by_id(augroup)
        vim.g.startscreen_buf_id = nil
      end,
      once = false,
      group = augroup,
    })
  end)
end

function M.close()
  if vim.g.startscreen_buf_id ~= nil then
    vim.api.nvim_buf_delete(vim.g.startscreen_buf_id, { force = true })
  end
end

return M
