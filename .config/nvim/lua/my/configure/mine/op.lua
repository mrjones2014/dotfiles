return {
  localplugin('mrjones2014/op.nvim'),
  run = 'make install',
  config = function()
    require('op').setup({
      sidebar = {
        side = 'left',
      },
      statusline_fmt = function(account)
        if not account or #account == 0 then
          return ' 1P: Signed Out'
        end

        return string.format(' 1P: %s', account)
      end,
    })
  end,
}
