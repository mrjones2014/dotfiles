return {
  sourceName = 'stylua',
  command = 'stylua',
  args = { '--search-parent-directories', '--stdin-filepath', '%filename', '-' },
  rootPatterns = { 'stylua.toml' },
}
