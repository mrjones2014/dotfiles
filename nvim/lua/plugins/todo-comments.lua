return {
  'folke/todo-comments.nvim',
  event = 'BufRead',
  opts = {
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
    --
    -- SAFETY: a safety comment for a Rust `unsafe { }` block
    --
    -- NB: nota bene
    --
    -- N.B. another nota bene
    highlight = {
      -- change pattern to not require a colon after the keyword
      pattern = [[.*<(KEYWORDS)\s*]],
      keyword = 'bg',
      comments_only = true,
    },
    -- search = { pattern = [[.*<(KEYWORDS)\s*]] },
    keywords = {
      SAFETY = { icon = '󰲉 ', color = 'warning' },
      NB = { icon = '󰴄 ', color = 'info', alt = { 'N.B.' } },
    },
  },
}
