---@type LazySpec
return {

  { 'mrjones2014/lua-gf.nvim', dev = true, ft = 'lua' },

  {
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
    opts = { sidebar = { side = 'left' } },
  },

  -- jj commit-message completion
  { 'yus-works/csc.nvim', ft = 'jjdescription', opts = {} },
}
