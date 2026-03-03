---@diagnostic disable-next-line -- optional parameters omitted
local filetypes = vim.list_extend(vim.deepcopy(require('my.ftconfig').filetypes), { 'conf', 'tmux', 'Onedarkpro' })

return {
  'NvChad/nvim-colorizer.lua',
  ft = filetypes,
  cmd = 'ColorizerAttachToBuffer',
  opts = {
    filetypes = filetypes,
    options = {
      always_update = true,
      parsers = {
        css = true,
        names = { enable = false },
      },
    },
  },
}
