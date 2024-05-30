return {
  'mrjones2014/smart-splits.nvim',
  dev = true,
  event = 'WinNew',
  ft = 'trouble', -- for some reason trouble.nvim doesn't trigger WinNew
  opts = { ignored_buftypes = { 'nofile' } },
}
