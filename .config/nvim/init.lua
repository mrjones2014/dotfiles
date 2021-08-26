require('disable-builtins')
require('settings')
require('keybinds')
require('custom-filetypes')
require('configure-trailing-whitespace')
require('configure-plugins-generic')
require('lsp-init')
require('plugins')

if vim.fn.getcwd() == (os.getenv('HOME') .. '/.config/nvim') then
  vim.cmd([[
    autocmd VimLeavePre * :PackerCompile
  ]])
end
