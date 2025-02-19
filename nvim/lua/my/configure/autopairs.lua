return {
  {
    'windwp/nvim-autopairs',
    event = { 'InsertEnter' },
    config = function()
      local Rule = require('nvim-autopairs.rule')
      local npairs = require('nvim-autopairs')
      local cond = require('nvim-autopairs.conds')
      npairs.setup({
        disable_in_filetype = { 'snacks_picker_input' },
      })
      -- <> pair for generics and stuff,
      -- complete <> if the preceding text is alphanumeric or :: for Rust
      npairs.add_rule(Rule('<', '>', {
        -- *exclude* these filetypes so that nvim-ts-autotag works instead
        '-html',
        '-javascriptreact',
        '-typescriptreact',
      }):with_pair(cond.before_regex('%a+:?:?$', 3)):with_move(function(opts)
        return opts.char == '>'
      end))
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact' },
    opts = {},
  },
}
