return {
  {
    'windwp/nvim-autopairs',
    event = { 'InsertEnter' },
    config = function()
      local Rule = require('nvim-autopairs.rule')
      local npairs = require('nvim-autopairs')
      local cond = require('nvim-autopairs.conds')
      npairs.setup({
        disable_filetype = { 'snacks_picker_input' },
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

      -- use autopairs to match bold, italic, etc. in markdown
      local function md_pair_cond(pair_len)
        return function(opts)
          local prev = opts.col > pair_len and opts.line:sub(opts.col - pair_len, opts.col - pair_len) or ''
          local next = opts.line:sub(opts.col, opts.col)
          return (prev == '' or prev:match('%s') ~= nil) and (next == '' or next:match('%s') ~= nil)
        end
      end
      npairs.add_rule(Rule('**', '**', 'markdown'):with_pair(md_pair_cond(2)):with_move())
      npairs.add_rule(Rule('_', '_', 'markdown'):with_pair(md_pair_cond(1)):with_move())
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact' },
    opts = {},
  },
}
