local root_dir = require('lspconfig.util').root_pattern('pnpm-workspace.yaml', 'package.json')
-- prioritize workspace roots
if
  vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yaml') > 0
  or vim.fn.filereadable(vim.loop.cwd() .. '/pnpm-workspace.yml') > 0
then
  root_dir = function()
    return vim.loop.cwd()
  end
end

return {
  root_dir = root_dir,
}
