return {
  localplugin('mrjones2014/smart-splits.nvim'),
  config = function()
    require('smart-splits').setup({
      tmux_integration = true,
    })
  end,
}
