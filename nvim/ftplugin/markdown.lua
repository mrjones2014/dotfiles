-- window-buffer-local scope: reverts automatically when another buffer is shown in this window
-- (`linebreak` is already on globally via AstroNvim defaults)
vim.wo[0][0].wrap = true

if vim.env.JJ_GH == '1' then
  -- 72 is the default max commit message length
  vim.wo.colorcolumn = '72'
end
