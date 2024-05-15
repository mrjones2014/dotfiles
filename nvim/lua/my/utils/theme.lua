---@class MyStatusLineColors
---@field black string
---@field gray string
---@field green string
---@field blue string
---@field base string
---@field surface0 string
---@field surface1 string
---@field surface2 string

---@return MyStatusLineColors
local function heirline_colors_tokyonight()
  local colors = require('tokyonight.colors').setup(require('my.configure.theme.tokyonight').opts)
  return {
    black = colors.bg_dark,
    gray = colors.dark5,
    green = colors.green,
    blue = colors.blue,
    base = colors.bg,
    surface0 = colors.fg_gutter,
    surface1 = colors.dark3,
    surface2 = colors.blue7,
  }
end

--- @return MyStatusLineColors
local function heirline_colors_catppuccin()
  local colors = require('catppuccin.palettes').get_palette('mocha')
  return {
    black = colors.crust,
    gray = colors.overlay1,
    green = colors.green,
    blue = colors.blue,
    base = colors.base,
    surface0 = colors.surface0,
    surface1 = colors.surface1,
    surface2 = colors.surface2,
  }
end

---@class MyThemeUtils
---@field heirline_colors MyStatusLineColors

---@type MyThemeUtils
return {
  -- when I switch themes, add a new function above and swap this out
  heirline_colors = heirline_colors_tokyonight(),
}
