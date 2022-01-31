local M = {}

local functions = require('keymap.functions')

local function bind(keymaps)
  for _, keymap in pairs(keymaps) do
    local opts = keymap.opts or {}
    if opts.silent == nil then
      opts.silent = true
    end
    vim.keymap.set(keymap.mode or 'n', keymap[1], keymap[2], opts)
  end
end

function M.apply_default_keymaps()
  bind({
    -- jk is mapped to escape by better-escape.nvim plugin
    -- make escape work in terminal mode
    { '<ESC>', '<C-\\><C-n>', mode = 't' },
    { 'jk', '<C-\\><C-n>', mode = 't' },

    -- leader+s to save all
    { '<leader>s', ':wa<cr>' },

    -- shift+w to close buffer
    { 'W', ':Bdelete<cr>' },

    -- ctrl+y and ctrl+u to resize splits
    { '<C-y>', functions.resize_split('plus') },
    { '<C-u>', functions.resize_split('minus') },

    -- remap gx to open url under cursor since I have netrw disabled
    { 'gx', functions.open_url_under_cursor },

    -- Navigator.nvim
    { '<C-h>', functions.navigator_lazy('left') },
    { '<C-j>', functions.navigator_lazy('down') },
    { '<C-k>', functions.navigator_lazy('up') },
    { '<C-l>', functions.navigator_lazy('right') },

    -- Bufferline
    { '<S-Right>', ':BufferLineCycleNext<CR>' },
    { '<S-Left>', ':BufferLineCyclePrev<CR>' },

    -- NvimTree
    { '<F3>', ':NvimTreeToggle<CR>' },

    -- Telescope
    { 'ff', functions.telescope_lazy('find_files') },
    { 'fb', functions.telescope_lazy('buffers') },
    { 'ft', functions.telescope_lazy('live_grep') },
    { 'fh', functions.telescope_lazy('oldfiles', { only_cwd = true }) },
    { '<leader>v', functions.telescope_lazy('find_files', _, true) },
    { '<leader>b', functions.telescope_lazy('buffers', _, true) },

    -- Trouble
    { '<leader>d', ':TroubleToggle<CR>' },

    -- nvim-comment
    { '<leader>c', ':CommentToggle<CR>' },
    { '<leader>c', ":'<,'>CommentToggle<CR>", mode = 'v' },
  })
end

function M.apply_lsp_keymaps()
  bind({
    { 'gd', vim.lsp.buf.definition },
    { 'gh', vim.lsp.buf.hover },
    { 'gi', vim.lsp.buf.implementation },
    { 'gt', vim.lsp.buf.type_definition },
    { 'gs', vim.lsp.buf.signature_help },
    { 'gr', vim.lsp.buf.references },
    { 'rn', vim.lsp.buf.rename },
    { 'F', vim.lsp.buf.code_action },
    { '[', vim.diagnostic.goto_prev },
    { ']', vim.diagnostic.goto_next },
  })
end

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
