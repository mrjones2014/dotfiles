require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "jsdoc",
    "html",
    "css",
    "yaml",
    "go",
    "comment",
    "lua",
    "regex",
  },
  highlight = {
    enable = true,
  },
  rainbow = {
    enable = true,
  },
}
