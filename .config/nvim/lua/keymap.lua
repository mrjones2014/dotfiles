local M = {}

local function bind(keymaps)
  for _, keymap in pairs(keymaps) do
    local opts = keymap.opts or {}
    if opts.silent == nil then
      opts.silent = true
    end
    vim.keymap.set(keymap.mode or 'n', keymap[1], keymap[2], opts)
  end
end

-- wrapper to not `require` telescope until needed
local function telescope_lazy(builtin_name, args, vert_split)
  return function()
    if vert_split then
      vim.cmd('vsp')
    end
    require('telescope.builtin')[builtin_name](args)
  end
end

-- wrapper to not `require` Navigator.nvim until needed
local function navigator_lazy(direction)
  return function()
    require('Navigator')[direction]()
  end
end

function M.apply_default_keymaps()
  bind({
    -- jk is mapped to escape by better-escape.nvim plugin
    -- make escape work in terminal mode
    { '<ESC>', '<C-\\><C-n>', mode = 't' },
    { 'jk', '<C-\\><C-n>', mode = 't' },

    -- leader+q to quit, leader+s to save all
    { '<leader>q', ':qa<cr>' },
    { '<leader>s', ':wa<cr>' },

    -- shift+w to close buffer
    { 'W', ':bw<cr>' },

    -- Navigator.nvim
    { '<C-h>', navigator_lazy('left') },
    { '<C-j>', navigator_lazy('down') },
    { '<C-k>', navigator_lazy('up') },
    { '<C-l>', navigator_lazy('right') },

    -- Bufferline
    { '<C-w>n', ':BufferLineCycleNext<CR>' },
    { '<C-w>p', ':BufferLineCyclePrev<CR>' },

    -- NvimTree
    { '<F3>', ':NvimTreeToggle<CR>' },

    -- Telescope
    { 'ff', telescope_lazy('find_files') },
    { 'fb', telescope_lazy('buffers') },
    { 'ft', telescope_lazy('live_grep') },
    { 'fh', telescope_lazy('oldfiles', { only_cwd = true }) },
    { '<leader>v', telescope_lazy('find_files', _, true) },
    { '<leader>b', telescope_lazy('buffers', _, true) },

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
