local M = {}

---Open URL in default browser. Supports GitHub shorthands like `owner/repo`
---@param url string
function M.open(url)
  -- plugin paths as interpreted by plugin manager, e.g. mrjones2014/op.nvim
  if not string.match(url, '[a-z]*://[^ >,;]*') and string.match(url, '[%w%p\\-]*/[%w%p\\-]*') then
    url = string.format('https://github.com/%s', url)
  end
  vim.fn.jobstart({ vim.fn.has('macunix') ~= 0 and 'open' or 'xdg-open', url }, { detach = true })
end

return M
