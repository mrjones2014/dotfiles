local M = {}

M.default = {
  -- jk to escape, and make escape work in terminal mode
  { 'jk', '<ESC>', mode = 'i' },
  { '<ESC>', '<C-\\><C-n>', mode = 't' },
  { 'jk', '<C-\\><C-n>', mode = 't' },
  -- prefix all nested maps with <leader>
  { '<leader>', {
    { 'q', ':qa<CR>', mode = 'n' },
    { 's', ':wa<CR>', mode = 'n' },
  } },
  { 'W', ':exec "bdelete " . bufname()<CR>', mode = 'n' },
  -------------------------
  -- tmux-navigator
  -------------------------
  {
    -- normal mode for all nested maps
    mode = 'n',
    {
      { '<C-h>', ':lua require("Navigator").left()<CR>' },
      { '<C-j>', ':lua require("Navigator").down()<CR>' },
      { '<C-k>', ':lua require("Navigator").up()<CR>' },
      { '<C-l>', ':lua require("Navigator").right()<CR>' },
    },
  },
  -------------
  -- Bufferline
  -------------
  {
    -- normal mode for all nested maps
    mode = 'n',
    {
      { '<C-w>n', ':BufferLineCycleNext<CR>' },
      { '<C-w>p', ':BufferLineCyclePrev<CR>' },
    },
  },
  ------------
  -- nvim-tree
  ------------
  { '<F3>', ':NvimTreeToggle<CR>', mode = 'n' },
  --------
  -- FTerm
  --------
  { '<leader>t', ':lua require("FTerm").toggle()<CR>' },
  ------------
  -- Telescope
  ------------
  {
    -- normal mode for all nested maps
    mode = 'n',
    {
      -- prefix all nested maps with 'f'
      'f',
      {
        { 'f', ':Telescope find_files<CR>' },
        { 'b', ':Telescope buffers<CR>' },
        { 't', ':Telescope live_grep<CR>' },
        { 'h', ':Telescope oldfiles<CR>' },
      },
    },
    {
      -- prefix all nested maps with <leader>
      '<leader>',
      {
        { 'v', ':vsplit<CR>:Telescope find_files<CR>' },
        { 'b', ':vsplit<CR>:Telescope buffers<CR>' },
      },
    },
  },
  ---------------
  -- trouble.nvim
  ---------------
  { '<leader>d', ':LspTroubleToggle<CR>' },
  ----------------
  -- nvim-comment
  ----------------
  { '<leader>c', ':CommentToggle<CR>', mode = 'n' },
  { '<leader>c', ":'<,'>CommentToggle<CR>", mode = 'v' },
}

M.lsp = {
  -- normal mode for all LSP keymaps
  mode = 'n',
  {
    { 'gd', vim.lsp.buf.definition },
    { 'gh', vim.lsp.buf.hover },
    { 'gi', vim.lsp.buf.implementation },
    { 'gt', vim.lsp.buf.type_definition },
    { 'gs', vim.lsp.buf.signature_help },
    { 'gr', vim.lsp.buf.references },
    { 'F', ':Telescope lsp_code_actions<CR>' },
    { '[', vim.lsp.diagnostic.goto_prev },
    { ']', vim.lsp.diagnostic.goto_next },
    {
      '<leader>rn',
      function()
        require('renamer').rename()
      end,
    },
  },
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
