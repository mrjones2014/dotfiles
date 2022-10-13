return {
  'numToStr/Comment.nvim',
  after = 'nvim-treesitter',
  config = function()
    -- default mappings:
    -- {
    --   toggler = {
    --     ---Line-comment toggle keymap
    --     line = 'gcc',
    --     ---Block-comment toggle keymap
    --     block = 'gbc',
    --   },
    --   ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    --   opleader = {
    --       ---Line-comment keymap
    --       line = 'gc',
    --       ---Block-comment keymap
    --       block = 'gb',
    --   },
    --   ---LHS of extra mappings
    --   extra = {
    --       ---Add comment on the line above
    --       above = 'gcO',
    --       ---Add comment on the line below
    --       below = 'gco',
    --       ---Add comment at the end of line
    --       eol = 'gcA',
    --   }
    -- }
    require('Comment').setup({
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    })
  end,
}
