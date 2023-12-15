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
        if vim.bo.ft == 'minifiles' then
          minifiles.close()
        else
          local file = vim.api.nvim_buf_get_name(0)
          local file_exists = vim.fn.filereadable(file) ~= 0
          minifiles.open(file_exists and file or nil)
          minifiles.reveal_cwd()
        end
      end,
      desc = 'Open mini.files',
    },
  },
  opts = {
    content = {
      filter = function(entry)
        return entry.name ~= '.DS_Store' and entry.name ~= '.git' and entry.name ~= '.direnv'
      end,
      sort = function(entries)
        -- technically can filter entries here too, and checking gitignore for _every entry individually_
        -- like I would have to in `content.filter` above is too slow. Here we can give it _all_ the entries
        -- at once, which is much more performant.
        local all_paths = table.concat(
          vim
            .iter(entries)
            :map(function(entry)
              return entry.path
            end)
            :totable(),
          '\n'
        )
        local output_lines = {}
        local job_id = vim.fn.jobstart({ 'git', 'check-ignore', '--stdin' }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            output_lines = data
          end,
        })

        -- command failed to run
        if job_id < 1 then
          return entries
        end

        -- send paths via STDIN
        vim.fn.chansend(job_id, all_paths)
        vim.fn.chanclose(job_id, 'stdin')
        vim.fn.jobwait({ job_id })
        return require('mini.files').default_sort(vim
          .iter(entries)
          :filter(function(entry)
            return not vim.tbl_contains(output_lines, entry.path)
          end)
          :totable())
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
