-- if we're in a pnpm workspace, ignore all node_modules
local utils = require('utils')
local ignored_dirs = {}
local pnpm_workspace_config = ''

if vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yaml') > 0 then
  pnpm_workspace_config = vim.fn.system({ 'cat', 'pnpm-workspace.yaml' })
elseif vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yml') > 0 then
  pnpm_workspace_config = vim.fn.system({ 'cat', 'pnpm-workspace.yaml' })
end

if #pnpm_workspace_config > 0 then
  for _, s in pairs(utils.split_to_lines(pnpm_workspace_config)) do
    local trimmed = utils.trim_str(s)
    if trimmed:sub(1, 1) == '-' and not string.find(trimmed, '*') then
      table.insert(ignored_dirs, string.format('./%s/node_modules', utils.trim_str(trimmed:sub(2)):gsub('"', '')))
    end
  end
end

require('lspconfig').rust_analyzer.setup({
  on_attach = require('lsp.utils').on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      files = {
        excludeDirs = ignored_dirs,
      },
    },
  },
})
