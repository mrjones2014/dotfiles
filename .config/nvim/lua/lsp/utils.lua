local lspUtils = {}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function lspUtils.on_attach(client, bufnr)
  vim.cmd('command! Format :lua require("lsp/utils").formatDocument()')
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'F', '<Cmd>lua require("telescope.builtin").lsp_code_actions()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)

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
    -- Disable formatting via tsserver because we're handling formatting via diagnosticls
    client.resolved_capabilities.document_formatting = false
  end
end

function lspUtils.formatDocument()
  local ft = vim.bo.filetype
  if ft == 'lua' then
    require('stylua-nvim').format_file()
    return
  end

  -- check if LSP is attached
  if (#vim.lsp.buf_get_clients()) < 1 then
    return
  end

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

return lspUtils
