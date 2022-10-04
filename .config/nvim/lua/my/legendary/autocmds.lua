local M = {}

function M.default_autocmds()
  return {
    {
      'BufReadPost',
      [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif]],
    },
    {
      name = 'JsonOptions',
      {
        'FileType',
        ':setlocal conceallevel=0',
        opts = { pattern = 'json' },
      },
    },
    {
      name = 'MarkdownOptions',
      {
        'FileType',
        ':setlocal wrap linebreak',
        opts = { pattern = 'markdown' },
      },
    },
    {
      name = 'JsoncFiletypeDetection',
      {
        { 'BufRead', 'BufNewFile' },
        ':set filetype=jsonc',
        opts = {
          pattern = { '*.jsonc', 'tsconfig*.json' },
        },
      },
    },
    {
      -- turn current line blame off in insert mode,
      -- back on when leaving insert mode
      name = 'GitSignsCurrentLineBlameInsertModeToggle',
      {
        { 'InsertLeave', 'InsertEnter' },
        function()
          local enabled = require('gitsigns.config').config.current_line_blame
          local mode = vim.fn.mode()
          if (mode == 'i' and enabled) or (mode ~= 'i' and not enabled) then
            vim.cmd.Gitsigns('toggle_current_line_blame')
          end
        end,
      },
    },
    {
      name = 'LuasnipJumpsClearOnModeChange',
      {
        'InsertLeave',
        function()
          require('luasnip').unlink_current()
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
    {
      -- recompile OneDarkPro.nvim cache on :PackerCompile
      name = 'RecompileOnedarkproCache',
      {
        'User',
        ':OnedarkproCache',
        opts = {
          pattern = 'PackerCompileDone',
        },
      },
    },
  }
end

function M.lsp_autocmds(bufnr, server_name)
  local _, autocmds = pcall(vim.api.nvim_get_autocmds, { group = 'LspOnAttachAutocmds' })
  autocmds = (type(autocmds) == 'table' and autocmds) or {}
  local augroup = {
    name = 'LspOnAttachAutocmds',
    clear = false,
  }

  if
    #vim.tbl_filter(function(autocmd)
      return autocmd.buflocal == true and autocmd.buffer == bufnr and autocmd.event == 'CursorHold'
    end, autocmds) == 0
  then
    table.insert(augroup, {
      'CursorHold',
      require('legendary.helpers').lazy(
        vim.diagnostic.open_float,
        nil,
        { focus = false, scope = 'cursor', border = 'rounded' }
      ),
      opts = { buffer = bufnr },
    })
  end

  if
    #vim.tbl_filter(function(autocmd)
      return autocmd.buflocal == true
        and autocmd.buffer == bufnr
        and (autocmd.event == 'BufEnter' or autocmd.event == 'BufEnter')
    end, autocmds) == 0
  then
    table.insert(augroup, {
      'BufEnter',
      function()
        -- reattach if we reopen a previously closed buffer
        vim.tbl_map(function(client)
          require('my.lsp.utils').on_attach(client, bufnr)
        end, vim.lsp.buf_get_clients(bufnr))
      end,
      opts = { buffer = bufnr },
    })
  end

  if
    server_name == 'null-ls'
    and #vim.tbl_filter(function(autocmd)
        return autocmd.buflocal == true and autocmd.buffer == bufnr and autocmd.event == 'BufWritePost'
      end, autocmds)
      == 0
  then
    table.insert(augroup, {
      'BufWritePost',
      require('my.lsp.utils').format_document,
      opts = { buffer = bufnr },
    })
  end

  if #augroup == 0 then
    return {}
  end

  return { augroup }
end

return M
