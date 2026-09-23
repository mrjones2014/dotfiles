-- AstroNvim leaves blink's `border` unset, so the windows inherit `vim.o.winborder`,
-- which AstroNvim sets to "rounded". Set it explicitly to drop the borders.
---@type LazySpec
return {
  'saghen/blink.cmp',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      -- AstroNvim sets `list.selection.preselect = false`, so plain 'accept' is a
      -- no-op when nothing is highlighted. 'select_and_accept' takes the first item.
      ['<CR>'] = { 'select_and_accept', 'fallback' },
    },
    completion = {
      -- AstroNvim sets preselect = false; blink's own default (and my old config's
      -- behaviour) is to highlight the first entry
      list = { selection = { preselect = true } },
      menu = { border = 'none' },
      documentation = { window = { border = 'none' } },
    },
    signature = { window = { border = 'none' } },
    cmdline = {
      -- AstroNvim leaves the cmdline menu off; my old config had it auto-showing
      completion = { menu = { auto_show = true } },
    },
  },
}
