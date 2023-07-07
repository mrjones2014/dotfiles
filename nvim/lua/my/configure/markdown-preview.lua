return {
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'md' },
    init = function()
      vim.g.mkdp_theme = 'dark'
    end,
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
  {
    'gaoDean/autolist.nvim',
    ft = 'markdown',
    init = function()
      vim.keymap.set('i', '<tab>', '<cmd>AutolistTab<cr>')
      vim.keymap.set('i', '<s-tab>', '<cmd>AutolistShiftTab<cr>')
      vim.keymap.set('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>')
      vim.keymap.set('n', 'o', 'o<cmd>AutolistNewBullet<cr>')
      vim.keymap.set('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>')
      vim.keymap.set('n', '<CR>', '<cmd>AutolistToggleCheckbox<cr><CR>')
      vim.keymap.set('n', '<C-r>', '<cmd>AutolistRecalculate<cr>')
    end,
    config = true,
  },
}
