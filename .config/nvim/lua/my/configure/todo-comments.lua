return {
  'folke/todo-comments.nvim',
  event = 'BufRead',
  config = function()
    -- See result with below comments
    -- TODO a todo message
    -- FIX Fix me
    -- BUG this is a bug
    -- PERF performance note
    -- NOTE just a note
    -- HACK this is a hack
    -- WARN this is a warning
    -- WARNING this is also a warning
    --
    -- TODO with a very long
    --      multiline comment
    require('todo-comments').setup({
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*]],
        keyword = 'bg',
        comments_only = true,
      },
    })
  end,
}
