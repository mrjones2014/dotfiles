local M = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.on_attach(client, bufnr)
  vim.cmd('command! Format :lua require("lsp.utils").formatDocument()')
  vim.cmd([[
    augroup fmt
      autocmd!
      autocmd BufWritePre * Format
    augroup END
  ]])

  --Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- setup LSP-specific keymaps
  require('nest').applyKeymaps(require('modules.keymaps').lsp)

  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = {
      border = 'single',
    },
    fix_pos = true,
    hint_enable = true,
    hint_prefix = '',
    padding = ' ',
  })

  local ft = vim.bo.filetype
  if
    ft == 'javascript'
    or ft == 'typescript'
    or ft == 'javascriptreact'
    or ft == 'typescriptreact'
    or ft == 'json'
    or ft == 'jsonc'
  then
    -- Disable formatting via tsserver because we're handling formatting via null-ls
    client.resolved_capabilities.document_formatting = false
  end
end

function M.formatDocument()
  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

  local ft = vim.bo.filetype
  if ft == 'javascript' or ft == 'typescript' or ft == 'javascriptreact' or ft == 'typescriptreact' then
    local params = {
      command = '_typescript.organizeImports',
      arguments = { vim.api.nvim_buf_get_name(0) },
      title = '',
    }
    vim.lsp.buf_request_sync(vim.api.nvim_get_current_buf(), 'workspace/executeCommand', params, 1500)
  end
  vim.lsp.buf.formatting_sync(nil, 1500)
end

function M.rename()
  local utils = require('modules.utils')
  local prompt_str = ' ' .. require('nvim-nonicons').get('file-directory') .. ' '
  local map_opts = { noremap = true, silent = true }
  local opts = {
    style = 'minimal',
    border = 'single',
    relative = 'cursor',
    width = 25,
    height = 1,
    row = 1,
    col = 1,
  }
  local buf, win = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, 'scrolloff', 0)
  vim.api.nvim_win_set_option(win, 'sidescrolloff', 0)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')

  vim.api.nvim_buf_add_highlight(buf, -1, 'LspRenamePrompt', 0, 0, #prompt_str)
  utils.highlight('LspRenamePrompt', 'None', 'Visual')

  vim.fn.prompt_setprompt(buf, prompt_str)

  vim.api.nvim_command('startinsert!')
  vim.api.nvim_buf_set_keymap(buf, 'i', '<esc>', '<CMD>stopinsert <BAR> q!<CR>', map_opts)
  vim.api.nvim_buf_set_keymap(
    buf,
    'i',
    '<CR>',
    "<CMD>stopinsert <BAR> lua require('lsp.utils')._rename()<CR>",
    map_opts
  )

  local function handler(...)
    local result
    local method
    local err = select(1, ...)
    local is_new = not select(4, ...) or type(select(4, ...)) ~= 'number'
    if is_new then
      method = select(3, ...).method
      result = select(2, ...)
    else
      method = select(2, ...)
      result = select(3, ...)
    end

    if err then
      vim.notify(("Error running LSP query '%s': %s"):format(method, err), vim.log.levels.ERROR)
      return
    end

    -- echo the resulting changes
    local new_word = ''
    if result and result.changes then
      local msg = ''
      for f, c in pairs(result.changes) do
        new_word = c[1].newText
        msg = msg .. ('%d changes -> %s'):format(#c, utils.get_relative_path(f)) .. '\n'
      end
      local currName = vim.fn.expand('<cword>')
      msg = msg:sub(1, #msg - 1)
      vim.notify(msg, vim.log.levels.INFO, { title = ('Rename: %s -> %s'):format(currName, new_word) })
    end

    vim.lsp.handlers[method](...)
  end

  function M._rename()
    local new_name = vim.trim(vim.fn.getline('.'):sub(5, -1))
    vim.cmd([[q!]])
    local params = vim.lsp.util.make_position_params()
    local curr_name = vim.fn.expand('<cword>')
    if not (new_name and #new_name > 0) or new_name == curr_name then
      return
    end
    params.newName = new_name
    vim.lsp.buf_request(0, 'textDocument/rename', params, handler)
  end
end

return M
