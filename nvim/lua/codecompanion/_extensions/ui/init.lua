local UiExtension = {}

function UiExtension.setup(opts)
  require('codecompanion-ui').setup(opts)
end

UiExtension.exports = {
  focus_input = function()
    require('codecompanion-ui').focus_input()
  end,
  is_visible = function()
    return require('codecompanion-ui').is_visible()
  end,
}

return UiExtension
