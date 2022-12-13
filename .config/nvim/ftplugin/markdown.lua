vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 3
vim.opt_local.concealcursor = 'n'

local function is_visual_mode(mode_str)
  if mode_str == 'nov' or mode_str == 'noV' or mode_str == 'no' then
    return false
  end

  return not not (string.find(mode_str:lower(), 'v') or string.find(mode_str:lower(), '') or mode_str == 'x')
end

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    if vim.v.event.new_mode == 'i' or is_visual_mode(vim.v.event.new_mode) then
      vim.opt_local.conceallevel = 0
    else
      vim.opt_local.conceallevel = 3
    end
  end,
  buffer = 0,
})
