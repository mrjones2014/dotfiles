return {
  'NMAC427/guess-indent.nvim',
  config = function()
    require('guess-indent').setup({
      filetype_exclude = {
        '',
        'nofile',
        'NvimTree',
        'TelescopePrompt',
      },
      buftype_exclude = {
        'help',
        'nofile',
        'terminal',
        'prompt',
        'NvimTree',
        'TelescopePrompt',
      },
    })
  end,
}
