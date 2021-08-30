local lsp = require('lspconfig')

-- customize LSP icons
local signs = require('modules.lsp-icons')
for type, icon in pairs(signs) do
  local hl = 'LspDiagnosticsSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

require('modules.load-all')(os.getenv('HOME') .. '/.config/nvim/lua/lsp', 2)

vim.cmd('command! Format :lua require("modules.lsp-utils").formatDocument()')
vim.cmd([[
  augroup fmt
    autocmd!
    autocmd BufWritePre * Format
  augroup END
]])
