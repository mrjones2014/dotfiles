local NuiExtension = {}

---Setup the autocmd events
function NuiExtension.setup(opts)
  opts = opts or {}
  require('codecompanion-nui').setup()
end

NuiExtension.exports = {
  focus_input = function()
    require('codecompanion-nui').focus_input()
  end,
  is_visible = function()
    return require('codecompanion-nui').is_visible()
  end,
}

return NuiExtension
