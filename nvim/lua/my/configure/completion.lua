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
    'L3MON4D3/LuaSnip',
    'folke/lazydev.nvim',
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
