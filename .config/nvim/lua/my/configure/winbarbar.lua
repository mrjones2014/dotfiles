-- use local while my PR is open
local paths = require('my.paths')
local plugin_path = 'mrjones2014/winbarbar.nvim'
if vim.fn.isdirectory(paths.join(paths.home, 'git/github/winbarbar.nvim')) > 0 then
  plugin_path = '~/git/github/winbarbar.nvim'
end

return {
  plugin_path,
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
      disabled_buftypes = {
        'nofile',
      },
    })
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufWinEnter', 'BufEnter' }, { command = 'BufferOrderByBufferNumber' })
  end,
}
