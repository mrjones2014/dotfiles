-- See result with below comments
-- TODO a todo message
-- FIX Fix me
-- BUG this is a bug
-- PERF performance note
-- NOTE just a note
-- HACK this is a hack
require('todo-comments').setup({
  merge_keywords = true,
  keywords = {
    WARNING = { icon = ' ', color = 'warning' },
  },
  highlight = {
    pattern = [[.*<(KEYWORDS)\s*]],
    keyword = 'bg',
    comments_only = true,
  },
  search = {
    pattern = [[\b(KEYWORDS)\b]],
  },
})
