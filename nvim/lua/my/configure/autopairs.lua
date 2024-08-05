return {
  {
    'windwp/nvim-autopairs',
    event = { 'InsertEnter' },
    config = function()
      local Rule = require('nvim-autopairs.rule')
      local npairs = require('nvim-autopairs')
      local cond = require('nvim-autopairs.conds')
      npairs.setup({})
      -- <> pair for generics and stuff,
      -- complete <> if the preceding text is alphanumeric or :: for Rust
      npairs.add_rule(Rule('<', '>'):with_pair(cond.before_regex('%a+:?:?', 3)):with_move(function(opts)
        return opts.char == '>'
      end))
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    lazy = false, -- unfortunately does not work when lazy loaded
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
