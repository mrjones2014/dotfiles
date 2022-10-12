return {
  localplugin('mrjones2014/winbarbar.nvim'),
  config = function()
    require('bufferline').setup({
      maximum_padding = 1,
      no_name_title = '[No Name]',
      disabled_filetypes = {
        'NvimTree',
        'TelescopePrompt',
        '1PasswordSidebar',
        'neotest-summary',
        'help',
        'Trouble',
        'nofile',
        'qf',
      },
    })
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufWinEnter', 'BufEnter' }, { command = 'BufferOrderByBufferNumber' })
  end,
}
