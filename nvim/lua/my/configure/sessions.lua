vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    local ok, persistence = pcall(require, 'persistence')
    if ok then
      persistence.load()
    end
  end,
})
return {
  'folke/persistence.nvim',
  opts = {},
}
