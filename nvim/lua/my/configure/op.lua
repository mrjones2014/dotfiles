return {
  'mrjones2014/op.nvim',
  dev = true,
  build = 'make install',
  cmd = {
    'OpSignin',
    'OpSignout',
    'OpWhoami',
    'OpCreate',
    'OpView',
    'OpEdit',
    'OpOpen',
    'OpInsert',
    'OpNote',
    'OpSidebar',
    'OpAnalyzeBuffer',
  },
  opts = {
    sidebar = {
      side = 'left',
    },
    statusline_fmt = function(account)
      if not account or #account == 0 then
        return ' 1P: Signed Out'
      end

      return string.format(' 1P: %s', account)
    end,
  },
}
