local show_ignored = false
local dim_ignored = true

local never_show = {
  ['.DS_Store'] = true,
  ['.git'] = true,
  ['.jj'] = true,
}

local filter_entry = function(fs_entry)
  return not never_show[fs_entry.name]
end

return {
  'nvim-mini/mini.files',
  dependencies = {
    {
      'folke/snacks.nvim',
      lazy = false,
      opts = { rename = { enabled = false } },
    },
  },
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
      filter = filter_entry,
      sort = function(fs_entries)
        local minifiles = require('mini.files')
        return minifiles.gitignore:sort_entries(fs_entries)
      end,
      highlight = function(fs_entry)
        local minifiles = require('mini.files')
        if not dim_ignored then
          return minifiles.default_highlight(fs_entry)
        end
        local path = fs_entry.path
        local dir = vim.fs.dirname(path)
        if minifiles.gitignore and minifiles.gitignore:is_file_ignored(dir, path) then
          return 'Comment'
        end
        return minifiles.default_highlight(fs_entry)
      end,
    },
    mappings = {
      go_in_plus = '<CR>',
    },
    windows = {
      preview = true,
      width_preview = 120,
    },
    options = { permanent_delete = false },
    gitignore = {
      max_cache_size = 200,
      max_concurrent_jobs = 10,
      prefetch_depth = 1,
    },
  },
  config = function(_, opts)
    local minifiles = require('mini.files')
    minifiles.setup(opts)
    minifiles.gitignore = require('my.mini_files_gitignore').new(opts, opts.gitignore)

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        require('snacks.rename').on_rename_file(event.data.from, event.data.to)
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesExplorerOpen',
      callback = function()
        minifiles.gitignore.state = show_ignored
        minifiles.gitignore:force_refresh()
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf = args.data.buf_id

        vim.keymap.set('n', '<ESC>', function()
          minifiles.close()
        end, { buffer = buf })

        vim.keymap.set('n', '<leader>gi', function()
          show_ignored = not show_ignored
          minifiles.gitignore.state = show_ignored
          minifiles.gitignore:force_refresh()
        end, { buffer = buf, desc = 'Toggle gitignore filtering' })

        vim.keymap.set('n', '<leader>gd', function()
          dim_ignored = not dim_ignored
          minifiles.refresh({ content = { force = true } })
        end, { buffer = buf, desc = 'Toggle dim ignored files' })

        vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = buf })
        vim.api.nvim_buf_set_name(buf, string.format('mini.files-%s', vim.uv.hrtime()))
        vim.api.nvim_create_autocmd('BufWriteCmd', {
          buffer = buf,
          callback = function()
            minifiles.synchronize()
          end,
        })

        vim.keymap.set('n', '<C-v>', function()
          vim.api.nvim_win_call(minifiles.get_explorer_state().target_window, function()
            vim.cmd.vsp()
            minifiles.set_target_window(vim.api.nvim_get_current_win())
          end)
          minifiles.go_in({ close_on_file = true })
        end, { desc = 'Open file in split window', buffer = buf })
      end,
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        if minifiles.gitignore then
          minifiles.gitignore:cleanup()
        end
      end,
    })
  end,
}
