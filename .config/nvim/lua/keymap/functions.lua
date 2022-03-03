local M = {}

function M.peek()
  require('nvim-treesitter.textobjects.lsp_interop').peek_definition_code('@block.outer')
end

-- wrapper to not `require` treesitter until needed
function M.incremental_selection(method)
  return function()
    require('nvim-treesitter.incremental_selection')[method]()
  end
end

-- wrapper to not `require` legendary.nvim until needed
function M.legendary()
  require('legendary').find()
end

-- wrapper to not `require` telescope until needed
function M.telescope_lazy(builtin_name, args)
  return function()
    require('telescope.builtin')[builtin_name](args)
  end
end

-- wrapper to not `require` Navigator.nvim until needed
function M.navigator_lazy(direction)
  return function()
    require('Navigator')[direction]()
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

function M.copy_rel_filepath()
  require('utils').copy_to_clipboard(require('paths').relative_filepath())
end

function M.copy_branch()
  require('utils').copy_to_clipboard(require('utils').git_branch())
end

function M.split_then(fn)
  return function()
    vim.cmd('vsp')
    fn()
  end
end

return M
