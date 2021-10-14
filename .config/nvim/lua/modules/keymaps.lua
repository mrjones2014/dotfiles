local M = {}

local function check_back_space()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

local function compe_autopairs_cr()
  if vim.fn.pumvisible() == 1 then
    return vim.fn['compe#confirm']({ keys = '<CR>', select = true })
  end
  return require('nvim-autopairs').autopairs_cr()
end

local function tab_complete()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  elseif check_back_space() then
    return '<Tab>'
  else
    return vim.fn['compe#complete']()
  end
end

local function shift_tab_complete()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  else
    return '<S-Tab>'
  end
end

local function esc_close_menu()
  if vim.fn.pumvisible() == 1 then
    return vim.fn['compe#close']()
  end

  return '<Esc>'
end

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
      { '<C-w>n', ':BufferlineCycleNext<CR>' },
      { '<C-w>p', ':BufferlineCyclePrev<CR>' },
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
  --------
  -- compe
  --------
  {
    -- insert mode and expr = true for all nested maps
    mode = 'i',
    options = { expr = true },
    {
      { '<Tab>', tab_complete },
      { '<S-Tab>', shift_tab_complete },
      { '<CR>', compe_autopairs_cr },
      { '<Esc>', esc_close_menu },
    },
  },
  {
    -- select mode and expr = true for all nested maps
    mode = 's',
    options = { expr = true },
    {
      { '<Tab>', tab_complete },
      { '<S-Tab>', shift_tab_complete },
    },
  },
  ---------------
  -- trouble.nvim
  ---------------
  { '<leader>d', ':LspTroubleToggle<CR>' },
  ----------------
  -- Komkommentary
  ----------------
  { '<leader>c', '<Plug>kommentary_line_default', mode = 'n' },
  { '<leader>c', '<Plug>kommentary_visual_default', mode = 'v' },
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
    { '<leader>rn', vim.lsp.buf.rename },
  },
}

return M
