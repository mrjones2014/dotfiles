local M = {}

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

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

    { '<leader>qq', ':wqa<CR>', description = 'Save all and quit' },

    {
      '<leader>gf',
      h.vsplit_then(function()
        vim.api.nvim_feedkeys('gf', 't', true)
      end),
      description = 'Split vertically, then go to file under cursor.',
    },

    {
      'gx',
      function()
        local url = vim.fn.expand('<cfile>')
        Url.open(url)
      end,
      description = 'Open URL under cursor',
    },

    { '<Tab>', ':bn<CR>', description = 'Move to next buffer' },
    { '<S-Tab>', ':bp<CR>', description = 'Move to previous buffer' },

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
        {
          '<leader>w',
          function()
            local word = vim.fn.expand('<cword>')
            require('telescope.builtin').live_grep({ default_text = word })
          end,
          description = 'Global search for word under cursor',
        },
      },
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
