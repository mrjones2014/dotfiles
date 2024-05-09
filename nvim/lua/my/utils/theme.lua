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

return {
  -- when I switch themes, add a new function above and swap this out
  heirline_colors = heirline_colors_tokyonight(),
}
