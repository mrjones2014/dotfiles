return {
  rootPatterns = { '.git' },
  command = './node_modules/.bin/prettier',
  args = { '--stdin-filepath', '%filepath' },
}
