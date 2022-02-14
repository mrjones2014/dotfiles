local M = {}

local functions = require('keymap.functions')

M.default_keymaps = {
  -- jk is mapped to escape by better-escape.nvim plugin
  -- make escape work in terminal mode
  { '<ESC>', '<C-\\><C-n>', mode = 't' },
  { 'jk', '<C-\\><C-n>', mode = 't' },

  { '<C-p>', functions.legendary_lazy(), description = 'Search keybinds and commands', mode = { 'n', 'i' } },

  { '<leader>s', ':wa<CR>', description = 'Write all buffers' },

  { 'W', ':Bdelete<CR>', description = 'Close current buffer' },

  { 'gx', functions.open_url_under_cursor, description = 'Open URL under cursor' },

  { '<C-h>', functions.navigator_lazy('left'), description = 'Move to next split left' },
  { '<C-j>', functions.navigator_lazy('down'), description = 'Move to next split down' },
  { '<C-k>', functions.navigator_lazy('up'), description = 'Move to next split up' },
  { '<C-l>', functions.navigator_lazy('right'), description = 'Move to next split right' },

  { '<S-Right>', ':BufferLineCycleNext<CR>', description = 'Move to next buffer' },
  { '<S-Left>', ':BufferLineCyclePrev<CR>', description = 'Move to previous buffer' },

  { '<F3>', ':NeoTreeShowToggle<CR>', description = 'Toggle file tree' },

  { 'gnn', functions.incremental_selection('init_selection'), description = 'Start selection with Treesitter' },
  { 'grn', functions.incremental_selection('node_incremental'), description = 'Expand selection to next Treesitter node' },
  { 'grm', functions.incremental_selection('node_decremental'), description = 'Shrink selection to next Treesitter node' },

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
  { '<leader><leader>s', ':source ~/.config/nvim/after/plugin/luasnip.lua<CR>', description = 'Reload snippets' },
}

M.default_commands = {
  { ':CopyBranch', functions.copy_branch, description = 'Copy current git branch name to clipboard' },
  { ':CopyFilepath', functions.copy_rel_filepath, description = 'Copy current relative filepath to clipboard' },
}

function M.get_lsp_keymaps(bufnr)
  return {
    { 'gh', vim.lsp.buf.hover, description = 'Show hover information', opts = { buffer = bufnr } },
    { 'gs', vim.lsp.buf.signature_help, description = 'Show signature help', opts = { buffer = bufnr } },
    { 'gr', vim.lsp.buf.references, description = 'Find references', opts = { buffer = bufnr } },
    { 'rn', vim.lsp.buf.rename, description = 'Rename symbol', opts = { buffer = bufnr } },
    { 'gd', vim.lsp.buf.definition, description = 'Go to definition', opts = { buffer = bufnr } },
    { 'gi', vim.lsp.buf.implementation, description = 'Go to implementation', opts = { buffer = bufnr } },
    { 'gt', vim.lsp.buf.type_definition, description = 'Go to type definition', opts = { buffer = bufnr } },
    { '<leader>p', require('lsp.utils.peek').peek_definition, description = 'Peek definition', opts = { buffer = bufnr } },
    {
      '<leader>gd',
      functions.split_then(vim.lsp.buf.definition),
      description = 'Go to definition in split',
      opts = { buffer = bufnr },
    },
    {
      '<leader>gi',
      functions.split_then(vim.lsp.buf.implementation),
      description = 'Go to implementation in split',
      opts = { buffer = bufnr },
    },
    {
      '<leader>gt',
      functions.split_then(vim.lsp.buf.type_definition),
      description = 'Go to type definition in split',
      opts = { buffer = bufnr },
    },
    { 'F', vim.lsp.buf.code_action, description = 'Show code actions', opts = { buffer = bufnr } },
    { '[', vim.diagnostic.goto_prev, description = 'Go to previous diagnostic item', opts = { buffer = bufnr } },
    { ']', vim.diagnostic.goto_next, description = 'Go to next diagnostic item', opts = { buffer = bufnr } },
  }
end

function M.get_cmp_mappings()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  return {
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif require('utils').has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }
end

return M
