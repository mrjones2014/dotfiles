local function deep_merge_with_list_append(tbl1, tbl2)
  -- If one of the tables is nil, return the other
  if tbl1 == nil then
    return tbl2
  end
  if tbl2 == nil then
    return tbl1
  end

  -- Check if both tables are lists
  if vim.islist(tbl1) and vim.islist(tbl2) then
    -- Append values from tbl2 to tbl1
    for _, v in ipairs(tbl2) do
      table.insert(tbl1, v)
    end
    return tbl1
  end

  -- Otherwise, assume both are dictionaries and merge recursively
  for k, v in pairs(tbl2) do
    if type(v) == 'table' and type(tbl1[k]) == 'table' then
      tbl1[k] = deep_merge_with_list_append(tbl1[k], v)
    else
      tbl1[k] = v
    end
  end

  return tbl1
end

return {
  'saghen/blink.cmp',
  version = '*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      keys = {
        {
          '<C-h>',
          function()
            require('luasnip').jump(-1)
          end,
          mode = { 'i', 's' },
          desc = 'Jump to previous snippet node',
        },
        {
          '<C-l>',
          function()
            local ls = require('luasnip')
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            end
          end,
          mode = { 'i', 's' },
          desc = 'Expand or jump to next snippet node',
        },
        {
          '<C-j>',
          function()
            local ls = require('luasnip')
            if ls.choice_active() then
              ls.change_choice(-1)
            end
          end,
          mode = { 'i', 's' },
          desc = 'Select previous choice in snippet choice nodes',
        },
        {
          '<C-k>',
          function()
            local ls = require('luasnip')
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end,
          mode = { 'i', 's' },
          desc = 'Select next choice in snippet choice nodes',
        },
        {
          '<C-s>',
          function()
            require('luasnip').unlink_current()
          end,
          mode = { 'i', 'n' },
          desc = 'Clear snippet jumps',
        },
      },
    },
    { 'folke/lazydev.nvim' },
  },
  opts = function(_, opts)
    deep_merge_with_list_append(opts, {
      snippets = { preset = 'luasnip' },
      signature = { enabled = true },
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Left>'] = {},
        ['<Right>'] = {},
      },
      completion = {
        menu = {
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind' },
            },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 0 },
        ghost_text = { enabled = true },
      },
      cmdline = {
        keymap = {
          ['<Left>'] = {},
          ['<Right>'] = { 'accept', 'fallback' },
        },
        completion = {
          menu = { auto_show = true },
        },
      },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          minifiles = {},
        },
        providers = {
          lsp = {
            -- LSP suggestions should be near top
            score_offset = 50,
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- boost lazydev suggestions to top
            score_offset = 100,
          },
        },
      },
    })
  end,
}
