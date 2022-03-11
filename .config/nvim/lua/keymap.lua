local M = {}

function M.default_keymaps()
  local h = require('legendary.helpers')
  return {
    -- jk is mapped to escape by better-escape.nvim plugin
    -- make escape work in terminal mode
    { '<ESC>', '<C-\\><C-n>', mode = 't' },
    { 'jk', '<C-\\><C-n>', mode = 't' },

    { '<C-p>', require('legendary').find, description = 'Search keybinds and commands', mode = { 'n', 'i', 'v' } },

    { '<leader>s', ':wa<CR>', description = 'Write all buffers' },

    { 'W', ':Bdelete<CR>', description = 'Close current buffer' },

    { 'gx', require('utils').open_url_under_cursor, description = 'Open URL under cursor' },

    { '<C-h>', h.lazy_required_fn('Navigator', 'left'), description = 'Move to next split left' },
    { '<C-j>', h.lazy_required_fn('Navigator', 'down'), description = 'Move to next split down' },
    { '<C-k>', h.lazy_required_fn('Navigator', 'up'), description = 'Move to next split up' },
    { '<C-l>', h.lazy_required_fn('Navigator', 'right'), description = 'Move to next split right' },

    { '<S-Right>', ':BufferLineCycleNext<CR>', description = 'Move to next buffer' },
    { '<S-Left>', ':BufferLineCyclePrev<CR>', description = 'Move to previous buffer' },

    { '<F3>', ':NvimTreeToggle<CR>', description = 'Toggle file tree' },

    {
      'gnn',
      h.lazy_required_fn('nvim-treesitter.incremental_selection', 'init_selection'),
      description = 'Start selection with Treesitter',
    },
    {
      'grn',
      h.lazy_required_fn('nvim-treesitter.incremental_selection', 'node_incremental'),
      description = 'Expand selection to next Treesitter node',
    },
    {
      'grm',
      h.lazy_required_fn('nvim-treesitter.incremental_selection', 'node_decremental'),
      description = 'Shrink selection to next Treesitter node',
    },

    { 'ff', h.lazy_required_fn('telescope.builtin', 'find_files'), description = 'Find files' },
    { 'fb', h.lazy_required_fn('telescope.builtin', 'buffers'), description = 'Find open buffers' },
    { 'ft', h.lazy_required_fn('telescope.builtin', 'live_grep'), description = 'Find pattern' },
    {
      'fh',
      h.lazy_required_fn('telescope.builtin', 'oldfiles', { only_cwd = true }),
      description = 'Find recent files',
    },
    {
      '<leader>f',
      h.vsplit_then(h.lazy_required_fn('telescope.builtin', 'find_files')),
      description = 'Split vertically, then find files',
    },
    {
      '<leader>b',
      h.vsplit_then(h.lazy_required_fn('telescope.builtin', 'buffers')),
      description = 'Split vertically, then find open buffers',
    },
    {
      '<leader>h',
      h.vsplit_then(h.lazy_required_fn('telescope.builtin', 'oldfiles', { only_cwd = true })),
      description = 'Split vertically, then find recent files',
    },
    {
      '<leader>t',
      h.vsplit_then(h.lazy_required_fn('telescope.builtin', 'live_grep')),
      description = 'Split vertically, then find file via live grep',
    },

    { '<leader>d', ':TroubleToggle<CR>', description = 'Open LSP diagnostics in quickfix window' },

    {
      '<leader>c',
      function(visual_selection)
        if visual_selection then
          vim.cmd(":'<,'>CommentToggle")
        else
          vim.cmd(':CommentToggle')
        end
      end,
      description = 'Toggle comment',
      mode = { 'n', 'v' },
    },
  }
end

function M.lsp_keymaps(bufnr)
  local h = require('legendary.helpers')
  return {
    { 'gh', vim.lsp.buf.hover, description = 'Show hover information', opts = { buffer = bufnr } },
    { 'gs', vim.lsp.buf.signature_help, description = 'Show signature help', opts = { buffer = bufnr } },
    {
      'gr',
      h.lazy_required_fn('telescope.builtin', 'lsp_references'),
      description = 'Find references',
      opts = { buffer = bufnr },
    },
    { 'gd', vim.lsp.buf.definition, description = 'Go to definition', opts = { buffer = bufnr } },
    { 'gi', vim.lsp.buf.implementation, description = 'Go to implementation', opts = { buffer = bufnr } },
    { 'gt', vim.lsp.buf.type_definition, description = 'Go to type definition', opts = { buffer = bufnr } },
    { '<leader>rn', vim.lsp.buf.rename, description = 'Rename symbol', opts = { buffer = bufnr } },
    {
      '<leader>p',
      h.lazy_required_fn('nvim-treesitter.textobjects.lsp_interop', 'peek_definition_code', '@block.outer'),
      description = 'Peek definition',
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
    { '[', vim.diagnostic.goto_prev, description = 'Go to previous diagnostic item', opts = { buffer = bufnr } },
    { ']', vim.diagnostic.goto_next, description = 'Go to next diagnostic item', opts = { buffer = bufnr } },
  }
end

function M.cmp_mappings()
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
