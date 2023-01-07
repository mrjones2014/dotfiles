local M = {}

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.default_keymaps()
  local h = require('legendary.toolbox')
  return {
    { '<leader>qq', opts = { filetype = 'NvimTree' }, description = 'NvimTree: Open file in vertical split' },
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
      '<C-p>',
      function()
        require('legendary').find({ filters = require('legendary.filters').current_mode() })
      end,
      mode = { 'n', 'i', 'x' },
    },

    { '<leader>qq', ':wqa<CR>', description = 'Save all and quit' },

    -- :Bwipeout comes from bufdelete.nvim
    { 'W', ':Bwipeout<CR>', description = 'Close current buffer' },

    {
      'gx',
      function()
        local url = vim.fn.expand('<cfile>')
        -- plugin paths as interpreted by plugin manager, e.g. mrjones2014/op.nvim
        if not string.match(url, '[a-z]*://[^ >,;]*') and string.match(url, '[%w%p\\-]*/[%w%p\\-]*') then
          url = string.format('https://github.com/%s', url)
        end
        vim.fn.jobstart({ 'open', url }, { detach = true })
      end,
      description = 'Open URL under cursor',
    },

    { '<Tab>', ':bn<CR>', description = 'Move to next buffer' },
    { '<S-Tab>', ':bp<CR>', description = 'Move to previous buffer' },

    {
      itemgroup = 'Workspace',
      description = 'nvim-ide commands',
      icon = '',
      keymaps = {
        { '<F3>', ':Workspace LeftPanelToggle<CR>', description = 'Toggle left IDE panel' },
        { '<F4>', ':Workspace RightPanelToggle<CR>', description = 'Toggle right IDE panel' },
      },
    },

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
    {
      '<leader>qs',
      h.lazy_required_fn('query-secretary', 'query_window_initiate'),
      description = 'Open Query Secretary',
    },

    {
      itemgroup = 'Search...',
      description = 'Various telescope.nvim finders',
      icon = ' ',
      keymaps = {
        -- ctrl+f from command line to search command history
        {
          '<C-f>',
          function()
            local search = vim.fn.getcmdline()
            vim.fn.setcmdline('')
            require('telescope.builtin').command_history({ default_text = search })
          end,
          description = 'Search command history',
          mode = 'c',
        },
        { 'fr', h.lazy_required_fn('telescope.builtin', 'resume'), description = 'Resume last Telescope finder' },
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
      },
    },

    { '<leader>d', ':TroubleToggle<CR>', description = 'Open LSP diagnostics in quickfix window' },

    {
      '<leader>w',
      [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
      description = 'Replace all instances of word under cursor in current buffer',
    },

    { '<leader>l', ':LegendaryScratchToggle<CR>', description = 'Toggle legendary.nvim scratchpad' },

    -- h/j/k/l mappings, split movement
    { '<C-h>', h.lazy_required_fn('smart-splits', 'move_cursor_left') },
    { '<C-j>', h.lazy_required_fn('smart-splits', 'move_cursor_down') },
    { '<C-k>', h.lazy_required_fn('smart-splits', 'move_cursor_up') },
    { '<C-l>', h.lazy_required_fn('smart-splits', 'move_cursor_right') },

    -- h/j/k/l mappings, split resizing
    { '<A-h>', h.lazy_required_fn('smart-splits', 'resize_left') },
    { '<A-l>', h.lazy_required_fn('smart-splits', 'resize_right') },
    { '<A-j>', h.lazy_required_fn('smart-splits', 'resize_down') },
    { '<A-k>', h.lazy_required_fn('smart-splits', 'resize_up') },

    -- h/j/k/l mappings, text moving
    {
      '<S-h>',
      {
        n = { ':MoveHChar(-1)<CR>' },
        x = { ":'<,'>MoveHBlock(-1)<CR>" },
      },
    },
    {
      '<S-j>',
      { n = ':MoveLine(1)<CR>', x = ":'<,'>MoveBlock(1)<CR>" },
    },
    {
      '<S-k>',
      { n = ':MoveLine(-1)<CR>', x = ":'<,'>MoveBlock(-1)<CR>" },
    },
    {
      '<S-l>',
      { n = ':MoveHChar(1)<CR>', x = ":'<,'>MoveHBlock(1)<CR>" },
    },

    -- spread
    {
      '<leader>so',
      h.lazy_required_fn('spread', 'out'),
      description = 'Split arrays/lists/etc. onto multiple lines',
    },
    {
      '<leader>si',
      h.lazy_required_fn('spread', 'combine'),
      description = 'Join arrays/lists/etc. onto a single line',
    },

    -- luasnip
    {
      '<C-h>',
      h.lazy_required_fn('luasnip', 'jump', -1),
      mode = { 'i', 's' },
      description = 'Jump to previous snippet node',
    },
    {
      '<C-l>',
      function()
        local ls = require('luasnip')
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end,
      mode = { 'i', 's' },
      description = 'Expand or jump to next snippet node',
    },
    {
      '<C-j>',
      function()
        local ls = require('luasnip')
        if ls.choice_active() then
          ls.change_choice(-1)
        end
      end,
      mode = { 'i', 's' },
      description = 'Select previous choice in snippet choice nodes',
    },
    {
      '<C-k>',
      function()
        local ls = require('luasnip')
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end,
      mode = { 'i', 's' },
      description = 'Select next choice in snippet choice nodes',
    },
    {
      '<C-s>',
      h.lazy_required_fn('luasnip', 'unlink_current'),
      mode = { 'i', 'n' },
      description = 'Clear snippet jumps',
    },
  }
end

function M.lsp_keymaps(bufnr)
  -- if the buffer already has LSP keymaps bound, do nothing
  if
    #vim.tbl_filter(function(keymap)
      return (keymap.desc or ''):lower() == 'rename symbol'
    end, vim.api.nvim_buf_get_keymap(bufnr, 'n')) > 0
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
        'fs',
        h.lazy_required_fn('telescope.builtin', 'lsp_document_symbols'),
        description = 'Find LSP document symbols',
      },
      {
        'gh',
        function()
          -- I have diagnostics float on CursorHold,
          -- disable that if I've manually shown the hover window
          -- see autocmds.lua, lsp_autocmds()
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
      { '<leader>n', vim.diagnostic.goto_next, description = 'Go to next diagnostic item', opts = { buffer = bufnr } },
    },
  }
end

function M.cmp_mappings()
  local cmp = require('cmp')
  return {
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, {
      'i',
      's',
      'c',
    }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, {
      'i',
      's',
      'c',
    }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
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
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {
      'i',
      's',
      'c',
    }),
    ['<C-d>'] = cmp.mapping({ i = cmp.mapping.scroll_docs(-4) }),
    ['<C-f>'] = cmp.mapping({ i = cmp.mapping.scroll_docs(4) }),
    ['<C-Space>'] = cmp.mapping({ c = cmp.mapping.confirm({ select = true }) }),
    ['<Right>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.mapping.confirm({ select = true })()
      else
        fallback()
      end
    end, {
      'c',
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-e>'] = cmp.mapping(function(fallback)
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
