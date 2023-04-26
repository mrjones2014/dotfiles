return {
  'rebelot/heirline.nvim',
  event = 'BufRead',
  config = function()
    local shared = require('my.configure.heirline.shared')
    local sc = require('my.configure.heirline.statuscolumn')

    require('heirline').setup({
      statuscolumn = {
        sc.LspDiagIcon,
        shared.Align,
        sc.LineNo,
        sc.GitIndicator,
        sc.Space,
      },
    })
  end,
}
