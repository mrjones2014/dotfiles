require'telescope'.setup{
  extensions = {
    fzf_writer = {
      minimum_grep_characters = 4,
      minimum_files_characters = 2,

      -- Disabled by default.
      -- Will probably slow down some aspects of the sorter, but can make color highlights.
      -- I will work on this more later.
      use_highlighter = true,
    }
  }
}
