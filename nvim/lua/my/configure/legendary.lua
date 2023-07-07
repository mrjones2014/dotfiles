return {
  'mrjones2014/legendary.nvim',
  dev = true,
  dependencies = {
    {
      'famiu/bufdelete.nvim',
      keys = {
        { 'W', ':Bwipeout<CR>', desc = 'Close current buffer' },
      },
    },
    -- used for frecency sort
    'kkharji/sqlite.lua',
    -- used sometimes for testing integrations
    -- {
    --   'folke/which-key.nvim',
    --   config = function()
    --     require('which-key').setup({
    --       plugins = {
    --         presets = {
    --           operators = false,
    --           motions = false,
    --           text_objects = false,
    --           windows = false,
    --           nav = false,
    --           z = false,
    --           g = false,
    --         },
    --       },
    --     })
    --     require('which-key').register({
    --       name = 'WhichKey: Files', -- optional group name
    --       desc = 'Some which key items',
    --       fq = { '<cmd>Telescope find_files<cr>', 'Find File' },
    --     })
    --   end,
    -- },
    -- {
    --   'nvim-tree/nvim-tree.lua',
    --   cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile', 'NvimTreeCollapse' },
    --   setup = true,
    -- },
  },
  keys = {
    { '<leader>l', ':LegendaryScratchToggle<CR>', desc = 'Toggle legendary.nvim scratchpad' },
    {
      '<C-p>',
      function()
        require('legendary').find({ filters = { require('legendary.filters').current_mode() } })
      end,
      mode = { 'n', 'i', 'x' },
    },
  },
  lazy = false,
  priority = 1000000,
  init = function()
    LSP.on_attach(function(client, bufnr)
      -- setup LSP-specific keymaps
      require('legendary').keymaps(require('my.legendary.keymap').lsp_keymaps(bufnr))
      require('legendary').commands(require('my.legendary.commands').lsp_commands(bufnr, client.name))
      require('legendary').autocmds(require('my.legendary.autocmds').lsp_autocmds(bufnr, client.name))
    end)
  end,
  opts = {
    keymaps = require('my.legendary.keymap').default_keymaps,
    commands = require('my.legendary.commands').default_commands,
    autocmds = require('my.legendary.autocmds').default_autocmds,
    funcs = require('my.legendary.functions').default_functions,
    col_separator_char = ' ',
    default_opts = {
      keymaps = { silent = true, noremap = true },
    },
    extensions = {
      -- nvim_tree = true,
      smart_splits = {
        mods = {
          swap = {
            prefix = '<leader><leader>',
            mod = '',
          },
        },
      },
      op_nvim = true,
      diffview = true,
    },
    lazy_nvim = { auto_register = true },
    -- which_key = { auto_register = true },
  },
}
