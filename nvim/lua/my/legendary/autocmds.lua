local M = {}

function M.default_autocmds()
  return {
    {
      'BufReadPost',
      [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif]],
    },
    {
      -- turn current line blame off in insert mode,
      -- back on when leaving insert mode
      name = 'GitSignsCurrentLineBlameInsertModeToggle',
      {
        { 'InsertLeave', 'InsertEnter' },
        function()
          local ok, gitsigns_config = pcall(require, 'gitsigns.config')
          if not ok then
            return
          end

          local enabled = gitsigns_config.config.current_line_blame
          local mode = vim.fn.mode()
          if (mode == 'i' and enabled) or (mode ~= 'i' and not enabled) then
            pcall(vim.cmd --[[@as function]], 'Gitsigns toggle_current_line_blame')
          end
        end,
      },
    },
    {
      name = 'MkdirOnWrite',
      {
        'BufWritePre',
        function()
          local dir = vim.fn.expand('<afile>:p:h')
          -- guard against URLs using netrw, :h netrw-transparent
          if dir:find('%l+://') == 1 then
            return
          end

          -- create potentially missing directories on write
          if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
          end
        end,
      },
    },
  }
end

return M
