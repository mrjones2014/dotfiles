return {
  'mrjones2014/op.nvim',
  dev = vim.fn.isdirectory(vim.fn.expand('~/git/op.nvim')) ~= 0,
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
