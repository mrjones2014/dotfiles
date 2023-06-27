return {
  {
    'folke/todo-comments.nvim',
    event = 'BufRead',
    config = true,
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
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*]],
        keyword = 'bg',
        comments_only = true,
      },
    },
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
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

      -- hack to not load ts_context_commentstring until actually needed by the hook
      local hook = nil
      require('Comment').setup({
        pre_hook = function(...)
          if hook == nil then
            hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
          end
          hook(...)
        end,
      })
    end,
  },
}
