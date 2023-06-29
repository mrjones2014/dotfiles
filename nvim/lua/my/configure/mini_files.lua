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
        if vim.bo.filetype == 'minifiles' then
          minifiles.close()
        else
          local current_file = vim.api.nvim_buf_get_name(0)
          local is_file = vim.fn.filereadable(current_file) ~= 0
          minifiles.open(vim.loop.cwd(), true)
          -- reveal current buffer in file tree
          if is_file then
            vim.schedule(function()
              local line = 1
              local entry = minifiles.get_fs_entry(0, line)
              while entry do
                if not entry then
                  return
                end
                -- if path matches exactly, we found the file, just set cursor to the right line
                if current_file == entry.path then
                  vim.api.nvim_win_set_cursor(0, { line, 1 })
                  return
                -- if buffer file name has the entry path as a prefix, open the directory
                elseif
                  current_file:find(
                    -- add trailing slash on directory path to avoid matching substrings
                    -- like `directory` matching `directory_other`;
                    -- we make it so `directory/` doesn't match `directory_other/`
                    string.format('%s/', entry.path),
                    1,
                    true
                  ) == 1
                then
                  vim.api.nvim_win_set_cursor(0, { line, 1 })
                  require('mini.files').go_in()
                  line = 1
                else
                  line = line + 1
                end
                entry = minifiles.get_fs_entry(0, line)
              end
            end)
          end
        end
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
