local M = {}

function M.default_commands()
  return {
    {
      ':CopyFilepath',
      function()
        require('utils').copy_to_clipboard(require('paths').relative_filepath())
      end,
      description = 'Copy current relative filepath to clipboard',
    },
    {
      ':CopyBranch',
      function()
        require('utils').copy_to_clipboard(require('utils').git_branch())
      end,
      description = 'Copy current git branch name to clipboard',
    },
    {
      ':Uuid',
      function()
        local uuid = vim.fn.system('uuidgen'):gsub('\n', ''):lower()
        local line = vim.fn.getline('.')
        vim.schedule(function()
          vim.fn.setline('.', vim.fn.strpart(line, 0, vim.fn.col('.')) .. uuid .. vim.fn.strpart(line, vim.fn.col('.')))
        end)
      end,
      description = 'Generate a UUID and insert it into the buffer',
    },
    {
      'Delete',
      function()
        local file = vim.fn.expand('%')
        vim.cmd('Bwipeout')
        vim.fn.system(string.format('rm %s', file))
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_err_writeln('Failed to delete file on disk.')
        end
      end,
    },
    {
      'Rename',
      function()
        local full_path = vim.fn.expand('%')
        vim.ui.input({ prompt = 'Rename to', default = vim.loop.cwd() .. '/' }, function(new_path)
          if not new_path then
            return
          end

          if vim.fn.filereadable(new_path) > 0 then
            vim.api.nvim_err_writeln('Cannot rename: file with specified name already exists.')
            return
          end
          local success = vim.loop.fs_rename(full_path, new_path)
          if not success then
            vim.api.nvim_err_writeln('Could not rename ' .. full_path .. ' to ' .. new_path)
            return
          end

          vim.api.nvim_out_write(full_path .. ' ➜ ' .. new_path)
          require('utils').rename_loaded_buffers(full_path, new_path)
          vim.cmd('NvimTreeRefresh')
        end)
      end,
    },
  }
end

function M.lsp_commands(bufnr, server_name)
  local commands = {
    {
      ':LspRestart',
      description = 'Restart any attached LSP clients',
      opts = { buffer = bufnr },
    },
    {
      ':LspStart',
      description = 'Start the LSP client manually',
      opts = { buffer = bufnr },
    },
    {
      ':LspInfo',
      description = 'Show attached LSP clients',
      opts = { buffer = bufnr },
    },
  }

  if server_name == 'null-ls' then
    table.insert(commands, 1, {
      ':Format',
      require('lsp.utils').format_document,
      description = 'Format the current document with LSP',
      opts = { buffer = bufnr },
    })
  end

  return commands
end

return M
