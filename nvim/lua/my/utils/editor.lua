local M = {}

function M.toggle_spellcheck()
  if vim.o.spell then
    vim.opt.spell = false
  else
    vim.opt.spelloptions = { 'camel', 'noplainbuffer' }
    vim.opt.spell = true
  end
end

function M.spellcheck_enabled()
  return vim.o.spell
end

return M
