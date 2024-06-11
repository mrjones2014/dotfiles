local M = {}

function M.default_keymaps()
  local h = require('legendary.toolbox')
  return {
    -- jk is mapped to escape by better-escape.nvim plugin
    -- make escape work in terminal mode,
    -- jk will enter vi mode of the shell itself
    { '<ESC>', '<C-\\><C-n>', mode = 't' },

    -- <ESC> clears hlsearch highlighting in normal mode
    { '<ESC>', ':noh<CR>', mode = 'n' },
    -- <leader>jk to clear notifications
    { '<leader>jk', ':Dismiss<CR>' },

    -- allow moving the cursor through wrapped lines using j and k,
    -- note that I have line wrapping turned off but turned on only for Markdown
    { 'j', 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', opts = { expr = true }, mode = { 'n', 'v' } },
    { 'k', 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', opts = { expr = true }, mode = { 'n', 'v' } },
    {
      '<leader>gf',
      h.vsplit_then(function()
        vim.api.nvim_feedkeys('gf', 't', true)
      end),
      description = 'Split vertically, then go to file under cursor.',
    },

    { '<Tab>', ':bn<CR>', description = 'Move to next buffer' },
    { '<S-Tab>', ':bp<CR>', description = 'Move to previous buffer' },

    {
      '<leader>s',
      function()
        if vim.o.spell then
          vim.opt.spell = false
        else
          vim.opt.spelloptions = { 'camel', 'noplainbuffer' }
          vim.opt.spell = true
        end
      end,
      description = 'Toggle spellcheck',
    },

    {
      '<C-;>',
      function()
        local line = vim.api.nvim_get_current_line()
        vim.api.nvim_set_current_line(string.format('%s;', line))
      end,
      mode = 'i',
      description = 'Add semicolon to end of line from insert mode',
    },
  }
end

function M.lsp_keymaps(bufnr)
  -- if the buffer already has LSP keymaps bound, do nothing
  if
    vim.iter(vim.api.nvim_buf_get_keymap(bufnr, 'n')):find(function(keymap)
      return (keymap.desc or ''):lower() == 'rename symbol'
    end)
  then
    return {}
  end

  local h = require('legendary.toolbox')
  return {
    itemgroup = 'LSP',
    description = 'Code navigation and other LSP items',
    icon = '',
    keymaps = {
      {
        'gh',
        function()
          -- I have diagnostics float on CursorHold,
          -- disable that if I've manually shown the hover window
          -- see require('my.utils.lsp').on_attach_default
          vim.cmd.set('eventignore+=CursorHold')
          vim.lsp.buf.hover()
          require('legendary').autocmd({
            'CursorMoved',
            ':set eventignore-=CursorHold',
            opts = { pattern = '<buffer>', once = true },
          })
        end,
        description = 'Show LSP hover menu',
        opts = { buffer = bufnr },
      },
      { 'gs', vim.lsp.buf.signature_help, description = 'Show signature help', opts = { buffer = bufnr } },
      { 'gr', vim.lsp.buf.references, description = 'Find references', opts = { buffer = bufnr } },
      { 'gd', vim.lsp.buf.definition, description = 'Go to definition', opts = { buffer = bufnr } },
      { 'gi', vim.lsp.buf.implementation, description = 'Go to implementation', opts = { buffer = bufnr } },
      { 'gt', vim.lsp.buf.type_definition, description = 'Go to type definition', opts = { buffer = bufnr } },
      { '<leader>rn', vim.lsp.buf.rename, description = 'Rename symbol', opts = { buffer = bufnr } },
      {
        'gpd',
        ':Glance definitions<CR>',
        description = 'Peek definition',
        opts = { buffer = bufnr },
      },
      {
        'gpi',
        ':Glance implementations<CR>',
        description = 'Peek implementation',
        opts = { buffer = bufnr },
      },
      {
        'gpt',
        ':Glance type_definitions<CR>',
        description = 'Peek type definitions',
        opts = { buffer = bufnr },
      },
      {
        '<leader>gd',
        h.vsplit_then(vim.lsp.buf.definition),
        description = 'Go to definition in split',
        opts = { buffer = bufnr },
      },
      {
        '<leader>gi',
        h.vsplit_then(vim.lsp.buf.implementation),
        description = 'Go to implementation in split',
        opts = { buffer = bufnr },
      },
      {
        '<leader>gt',
        h.vsplit_then(vim.lsp.buf.type_definition),
        description = 'Go to type definition in split',
        opts = { buffer = bufnr },
      },
      { 'F', vim.lsp.buf.code_action, description = 'Show code actions', opts = { buffer = bufnr } },
      {
        '<leader>p',
        vim.diagnostic.goto_prev,
        description = 'Go to previous diagnostic item',
        opts = { buffer = bufnr },
      },
    },
  }
end

return M
