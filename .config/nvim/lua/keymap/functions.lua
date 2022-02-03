local M = {}

-- wrapper to not `require` legendary.nvim until needed
function M.legendary_lazy()
  return function()
    require('legendary').find()
  end
end

-- wrapper to not `require` telescope until needed
function M.telescope_lazy(builtin_name, args, vert_split)
  return function()
    if vert_split then
      vim.cmd('vsp')
    end
    require('telescope.builtin')[builtin_name](args)
  end
end

-- wrapper to not `require` Navigator.nvim until needed
function M.navigator_lazy(direction)
  return function()
    require('Navigator')[direction]()
  end
end

function M.resize_split(plus_or_minus)
  return function()
    -- full height window height is screen height minus 3 for bufferline, status line, and command line
    local is_vert_split = vim.fn.winheight(vim.fn.winnr()) + 3 == vim.o.lines
    if is_vert_split then
      if plus_or_minus == 'plus' then
        vim.cmd('vertical resize +3')
      else
        vim.cmd('vertical resize -3')
      end
    else
      if plus_or_minus == 'plus' then
        vim.cmd('resize +3')
      else
        vim.cmd('resize -3')
      end
    end
  end
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

return M
