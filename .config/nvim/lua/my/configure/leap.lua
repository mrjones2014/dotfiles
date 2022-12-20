return {
  'ggandor/leap.nvim',
  keys = { 's', 'S' },
  config = function()
    require('leap').add_default_mappings()
  end,
}
