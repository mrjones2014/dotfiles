return {
  'windwp/nvim-autopairs',
  event = { 'InsertEnter' },
  config = function()
    local Rule = require('nvim-autopairs.rule')
    local npairs = require('nvim-autopairs')
    local cond = require('nvim-autopairs.conds')
    npairs.setup({})
    -- <> pair for generics and stuff
    npairs.add_rule(Rule('<', '>'):with_pair(cond.before_regex('%a+')):with_move(function(opts)
      return opts.char == '>'
    end))
  end,
}
