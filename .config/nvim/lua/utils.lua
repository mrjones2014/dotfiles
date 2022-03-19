local M = {}

function M.has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.copy_to_clipboard(str)
  vim.cmd(string.format('call jobstart("echo %s | pbcopy")', str))
end

function M.git_branch()
  return vim.g.gitsigns_head
end

function M.open_url_under_cursor()
  if vim.fn.has('mac') == 1 then
    vim.cmd('call jobstart(["open", expand("<cfile>")], {"detach": v:true})')
  elseif vim.fn.has('unix') == 1 then
    vim.cmd('call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})')
  else
    vim.notify('Error: gx is not supported on this OS!')
  end
end

function M.smart_win_resize(key)
  -- minus 3 for bufferline, status line, and cmd line
  local is_full_height = vim.api.nvim_win_get_height(0) == vim.o.lines - 3
  local is_full_width = vim.api.nvim_win_get_width(0) == vim.o.columns

  -- don't try to horizontally resize a full width window
  if (key == 'h' or key == 'l') and is_full_width then
    return
  end

  -- don't try to vertically resize a full height window
  if (key == 'j' or key == 'k') and is_full_height then
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  -- vertical
  if key == 'j' or key == 'k' then
    vim.cmd('wincmd k')
    local new_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd k')
    local new_win_2 = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
    -- top edge or middle of >2
    if cur_win == new_win or new_win == new_win_2 then
      if key == 'j' then
        vim.cmd('resize +3')
      else
        vim.cmd('resize -3')
      end
    else
      -- bottom edge
      if key == 'j' then
        vim.cmd('resize -3')
      else
        vim.cmd('resize +3')
      end
    end
  else
    vim.cmd('wincmd h')
    local new_win = vim.api.nvim_get_current_win()
    vim.cmd('wincmd h')
    local new_win2 = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(cur_win)
    -- left edge or middle of >2
    if cur_win == new_win or new_win == new_win2 then
      if key == 'l' then
        vim.cmd('vertical resize +3')
      else
        vim.cmd('vertical resize -3')
      end
    else
      -- not top edge
      if key == 'l' then
        vim.cmd('vertical resize -3')
      else
        vim.cmd('vertical resize +3')
      end
    end
  end
end

return M
