local M = {}

local functions = require('keymap.functions')

M.default_keymaps = {
  -- jk is mapped to escape by better-escape.nvim plugin
  -- make escape work in terminal mode
  { '<ESC>', '<C-\\><C-n>', mode = 't' },
  { 'jk', '<C-\\><C-n>', mode = 't' },

  { '<C-p>', ':Legendary<CR>', description = 'Search keybinds and commands', mode = { 'n', 'i' } },

  { '<leader>s', ':wa<CR>', description = 'Write all buffers' },

  { 'W', ':Bdelete<CR>', description = 'Close current buffer' },

  { '<C-y>', functions.resize_split('plus'), description = 'Resize split larger' },
  { '<C-u>', functions.resize_split('minus'), description = 'Resize split smaller' },

  { 'gx', functions.open_url_under_cursor, description = 'Open URL under cursor' },

  { '<C-h>', functions.navigator_lazy('left'), description = 'Move to next split left' },
  { '<C-j>', functions.navigator_lazy('down'), description = 'Move to next split down' },
  { '<C-k>', functions.navigator_lazy('up'), description = 'Move to next split up' },
  { '<C-l>', functions.navigator_lazy('right'), description = 'Move to next split right' },

  { '<S-Right>', ':BufferLineCycleNext<CR>', description = 'Move to next buffer' },
  { '<S-Left>', ':BufferLineCyclePrev<CR>', description = 'Move to previous buffer' },

  { '<F3>', ':NvimTreeToggle<CR>', description = 'Toggle file tree' },

  { 'ff', functions.telescope_lazy('find_files'), description = 'Find files' },
  { 'fb', functions.telescope_lazy('buffers'), description = 'Find open buffers' },
  { 'ft', functions.telescope_lazy('live_grep'), description = 'Find pattern' },
  { 'fh', functions.telescope_lazy('oldfiles', { only_cwd = true }), description = 'Find recent files' },
  { '<leader>v', functions.telescope_lazy('find_files', _, true), description = 'Split vertically, then find files' },
  {
    '<leader>b',
    functions.telescope_lazy('buffers', _, true),
    description = 'Split vertically, then find open buffers',
  },
  {
    '<leader>h',
    functions.telescope_lazy('oldfiles', { only_cwd = true }, true),
    description = 'Split vertically, then find recent files',
  },

  { '<leader>d', ':TroubleToggle<CR>', description = 'Open LSP diagnostics in quickfix window' },

  { '<leader>c', ':CommentToggle<CR>', description = 'Toggle comment' },
  { '<leader>c', ":'<,'>CommentToggle<CR>", mode = 'v', description = 'Toggle comment' },

  -- extra commands
  { ':qa<CR>', description = 'Quit all windows', nobind = true },
}

M.lsp_keymaps = {
  { 'gd', vim.lsp.buf.definition, description = 'Go to definition' },
  { 'gh', vim.lsp.buf.hover, description = 'Show hover information' },
  { 'gi', vim.lsp.buf.implementation, description = 'Go to implementation' },
  { 'gt', vim.lsp.buf.type_definition, description = 'Go to type definition' },
  { 'gs', vim.lsp.buf.signature_help, description = 'Show signature help' },
  { 'gr', vim.lsp.buf.references, description = 'Find references' },
  { 'rn', vim.lsp.buf.rename, description = 'Rename symbol' },
  { 'F', vim.lsp.buf.code_action, description = 'Show code actions' },
  { '[', vim.diagnostic.goto_prev, description = 'Go to previous diagnostic item' },
  { ']', vim.diagnostic.goto_next, description = 'Go to next diagnostic item' },

  -- extra LSP commands
  { ':Format', description = 'Format the current document with LSP', nobind = true },
}

function M.get_cmp_mappings()
  return {
    ['<S-Tab>'] = require('cmp').mapping.select_prev_item(),
    ['<Tab>'] = require('cmp').mapping.select_next_item(),
    ['<C-d>'] = require('cmp').mapping.scroll_docs(-4),
    ['<C-f>'] = require('cmp').mapping.scroll_docs(4),
    ['<CR>'] = require('cmp').mapping.confirm({ select = true }),
  }
end

return M
