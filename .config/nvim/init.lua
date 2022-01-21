if #vim.v.argv == 2 and vim.fn.isdirectory(vim.v.argv[2]) > 0 then
  vim.api.nvim_set_current_dir(vim.v.argv[2])
  vim.cmd('bw')
  vim.cmd('intro')
end

require('disable-builtins')
require('settings')
require('plugins')
require('keymap').apply_default_keymaps()
require('whitespace').setup()
