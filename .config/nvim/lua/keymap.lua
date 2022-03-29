local M = {}

local lsp_keymaps_bound_bufnrs = {}

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

    { '<C-h>', require('smart-splits').move_cursor_left, description = 'Move to next split left' },
    { '<C-j>', require('smart-splits').move_cursor_down, description = 'Move to next split down' },
    { '<C-k>', require('smart-splits').move_cursor_up, description = 'Move to next split up' },
    { '<C-l>', require('smart-splits').move_cursor_right, description = 'Move to next split right' },

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
      h.lazy_required_fn('telescope.builtin', 'oldfiles'),
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
      h.vsplit_then(h.lazy_required_fn('telescope.builtin', 'oldfiles')),
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
    {
      '<leader>w',
      [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
      description = 'Replace all instances of word under cursor in current buffer',
    },
    { '<C-e>', '<Plug>luasnip-next-choice', mode = { 'i', 's' } },
    {
      '<A-h>',
      require('smart-splits').resize_left,
      description = 'Smart resize vertically',
    },
    {
      '<A-l>',
      require('smart-splits').resize_right,
      description = 'Smart resize vertically',
    },
    {
      '<A-j>',
      require('smart-splits').resize_down,
      description = 'Smart resize horizontally',
    },
    {
      '<A-k>',
      require('smart-splits').resize_up,
      description = 'Smart resize horizontally',
    },
  }
end

function M.lsp_keymaps(bufnr)
  if vim.tbl_contains(lsp_keymaps_bound_bufnrs, bufnr) then
    return {}
  end

  table.insert(lsp_keymaps_bound_bufnrs, bufnr)
  local h = require('legendary.helpers')
  return {
    {
      'gh',
      function()
        -- I have diagnostics float on CursorHold,
        -- disable that if I've manually shown the hover window
        -- see autocmds.lua, lsp_autocmds()
        vim.cmd('set eventignore=CursorHold')
        vim.lsp.buf.hover()
        require('legendary').bind_autocmds({
          'CursorMoved',
          ':set eventignore=""',
          opts = { pattern = '<buffer>', once = true },
        })
      end,
      description = 'Show hover information',
      opts = { buffer = bufnr },
    },
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
      'gpd',
      h.lazy_required_fn('goto-preview', 'goto_preview_definition'),
      description = 'Peek definition',
      opts = { buffer = bufnr },
    },
    {
      'gpi',
      h.lazy_required_fn('goto-preview', 'goto_preview_implementation'),
      description = 'Peek implementation',
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
    { '<leader>a', h.lazy_required_fn('neogen', 'generate'), description = 'Generate doc comments' },
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
      'c',
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
      'c',
    }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping({ c = cmp.mapping.confirm({ select = true }) }),
    ['<Right>'] = cmp.mapping({
      c = cmp.mapping.confirm({ select = true }),
      i = function(fallback)
        if cmp.visible() then
          cmp.mapping.confirm({ select = true })()
        else
          fallback()
        end
      end,
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<ESC>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.mapping.close()()
      else
        fallback()
      end
    end, {
      'i',
      'c',
    }),
  }
end

return M
