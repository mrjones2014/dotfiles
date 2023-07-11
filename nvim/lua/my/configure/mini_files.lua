return {
  'echasnovski/mini.files',
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf = args.data.buf_id

        -- close with <ESC> as well as q
        vim.keymap.set('n', '<ESC>', function()
          require('mini.files').close()
        end, { buffer = buf })

        -- set up ability to confirm changes with :w
        vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')
        vim.api.nvim_buf_set_name(buf, string.format('mini.files-%s', vim.loop.hrtime()))
        vim.api.nvim_create_autocmd('BufWriteCmd', {
          buffer = buf,
          callback = function()
            require('mini.files').synchronize()
          end,
        })
      end,
    })
  end,
  keys = {
    {
      '<F3>',
      function()
        local minifiles = require('mini.files')
        local file = vim.api.nvim_buf_get_name(0)
        local file_exists = vim.fn.filereadable(file) ~= 0
        minifiles.open(file_exists and file or nil)
        minifiles.reveal_cwd()
      end,
      desc = 'Open mini.files',
    },
  },
  opts = {
    content = {
      filter = function(entry)
        return entry.name ~= '.DS_Store' and entry.name ~= '.git'
      end,
    },
    mappings = {
      go_in_plus = '<CR>',
    },
    windows = {
      preview = true,
      width_preview = 120,
    },
  },
}
