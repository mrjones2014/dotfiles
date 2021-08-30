return {
  command = './node_modules/.bin/stylelint',
  rootPatterns = { '.git' },
  debounce = 100,
  args = { '--formatter', 'json', '--stdin-filename', '%filepath' },
  sourceName = 'stylelint',
  parseJson = {
    errorsRoot = '[0].warnings',
    line = 'line',
    column = 'column',
    message = '${text}',
    security = 'severity',
  },
  securities = {
    error = 'error',
    warning = 'warning',
  },
}
