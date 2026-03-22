local NuiExtension = {}

---Setup the autocmd events
function NuiExtension.setup(opts)
  opts = opts or {}
  require('codecompanion-nui').setup()
end

return NuiExtension
