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
  },
}
