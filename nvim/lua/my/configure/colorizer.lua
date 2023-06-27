---@diagnostic disable-next-line -- optional parameters omitted
local filetypes = vim.list_extend(vim.deepcopy(require('my.lsp.filetypes').filetypes), { 'conf', 'tmux', 'Onedarkpro' })

return {
  'NvChad/nvim-colorizer.lua',
  ft = filetypes,
  cmd = 'ColorizerAttachToBuffer',
  opts = {
    filetypes = filetypes,
    user_default_options = {
      names = false,
      css = true,
      sass = { enable = true, parsers = { 'css' } },
      always_update = true,
    },
  },
}
