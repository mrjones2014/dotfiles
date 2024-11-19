local lsp_bound_buffer_ids = {}
return {
  {
    'folke/snacks.nvim',
    lazy = false,
    opts = { bufdelete = { enabled = true } },
    keys = {
      {
        'W',
        function()
          require('snacks.bufdelete').delete(0)
        end,
        desc = 'Close current buffer',
      },
    },
  },
  -- used for frecency sort
  'kkharji/sqlite.lua',
  {
    'mrjones2014/legendary.nvim',
    dev = true,
    dependencies = {

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
      --       name = 'WhichKey: Files',
      --       desc = 'Some which key items',
      --       fq = { '<cmd>Telescope find_files<cr>', 'Find File' },
      --     })
      --     require('which-key').register({
      --       ['<leader>'] = {
      --         f = {
      --           name = '+file',
      --           f = { '<cmd>Telescope find_files<cr>', 'Find File' },
      --           r = { '<cmd>Telescope oldfiles<cr>', 'Open Recent File' },
      --           n = { '<cmd>enew<cr>', 'New File' },
      --         },
      --       },
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
      require('my.utils.lsp').on_attach(function(_, bufnr)
        if vim.tbl_contains(lsp_bound_buffer_ids, bufnr) then
          return
        end
        -- setup LSP-specific keymaps
        require('legendary').keymaps(require('my.legendary.keymap').lsp_keymaps(bufnr))
        require('legendary').commands(require('my.legendary.commands').lsp_commands(bufnr))
        table.insert(lsp_bound_buffer_ids, bufnr)
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
        -- which_key = { auto_register = true },
        lazy_nvim = true,
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
    },
  },
}
