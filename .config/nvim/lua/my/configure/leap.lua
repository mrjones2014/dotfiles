return {
  'ggandor/leap.nvim',
  keys = { { 'n', 's' }, { 'n', 'S' } },
  config = function()
    require('leap').add_default_mappings()
  end,
}
