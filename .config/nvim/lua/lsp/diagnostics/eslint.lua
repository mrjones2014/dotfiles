return {
  sourceName = 'eslint',
  command = 'eslint_d',
  rootPatterns = { '.git' },
  debounce = 100,
  args = {
    '--stdin',
    '--stdin-filename',
    '%filepath',
    '--format',
    'json',
  },
  parseJson = {
    errorsRoot = '[0].messages',
    line = 'line',
    column = 'column',
    endLine = 'endLine',
    endColumn = 'endColumn',
    message = '${message} [${ruleId}]',
    security = 'severity',
  },
  securities = {
    [1] = 'error',
    [2] = 'warning',
  },
}
