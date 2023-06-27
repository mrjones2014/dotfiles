return {
  'echasnovski/mini.files',
  init = function()
    -- set up ability to confirm changes with :w
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function()
        vim.schedule(function()
          vim.api.nvim_buf_set_option(0, 'buftype', 'acwrite')
          vim.api.nvim_buf_set_name(0, require('mini.files').get_fs_entry(0, 1).path)
          vim.api.nvim_create_autocmd('BufWriteCmd', {
            buffer = 0,
            callback = function()
              require('mini.files').synchronize()
            end,
          })
        end)
      end,
    })
  end,
  keys = {
    {
      '<F3>',
      function()
        require('mini.files').open(vim.loop.cwd(), true)
      end,
      desc = 'Open mini.files',
    },
  },
  opts = {
    mappings = {
      go_in_plus = '<CR>',
    },
    windows = {
      preview = true,
      width_preview = 120,
    },
  },
  config = true,
}
