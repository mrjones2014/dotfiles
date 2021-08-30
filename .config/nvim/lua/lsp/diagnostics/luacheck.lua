return {
  sourceName = 'luacheck',
  command = 'luacheck',
  debounce = 100,
  args = { '--codes', '--no-color', '--quiet', '%filepath' },
  offsetLine = 0,
  offsetColumn = 0,
  formatLines = 1,
  formatPattern = {
    [[^.*:(\d+):(\d+):\s\(([W|E])\d+\)\s(.*)(\r|\n)*$]],
    { line = 1, column = 2, security = 3, message = { '[luacheck] ', 4 } },
  },
  securities = { E = 'error', W = 'warning' },
  rootPatterns = { '.luacheckrc' },
}
