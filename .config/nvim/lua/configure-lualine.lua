require('lualine').setup {
  options = {
    theme = "github",
  },
  sections = {
    lualine_a = {{"mode", lower = false}},
    lualine_b = {"branch"},
    lualine_c = {"filename"}
  },
  extensions = {"nvim-tree"}
}
