local formatters_by_ft = require('my.ftconfig').formatters_by_ft
local linters_by_ft = require('my.ftconfig').linters_by_ft
local lsp_util = require('my.utils.lsp')
lsp_util.on_attach(require('my.utils.lsp').on_attach_default)

-- wait for lazy to finish setting up runtime path before setting up LSPs
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  once = true,
  callback = function()
    -- enable all LSPs defined under lsp/
    vim.lsp.enable(vim
      .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
      :map(function(f)
        return vim.fn.fnamemodify(f, ':t:r')
      end)
      :totable())

    vim.lsp.config('*', {
      before_init = function(_, config)
        -- merge .vscode/settings.json into LSP settings
        local ok, codesettings = pcall(require, 'codesettings')
        if ok then
          config = codesettings.with_local_settings(config.name, config)
        end
      end,
    })
  end,
})

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd(string.format('tabnew %s', vim.lsp.log.get_filename()))
end, {
  desc = 'Opens the Nvim LSP client log.',
})

return {
  -- used to merge .vscode/settings.json into LSP settings
  {
    'mrjones2014/codesettings.nvim',
    dev = true,
    cmd = 'Codesettings',
    ft = { 'json', 'jsonc', 'lua' },
    opts = {},
    dependencies = {},
  },
  { 'MeanderingProgrammer/render-markdown.nvim', ft = { 'codesettings-output' } },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      'saghen/blink.cmp',
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        sources = {
          per_filetype = {
            lua = { inherit_defaults = true, 'lazydev' },
          },
          providers = {
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
              -- boost lazydev suggestions to top
              score_offset = 100,
            },
          },
        },
      },
    },
    opts = {
      enabled = true,
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'folke/snacks.nvim',
    lazy = false,
    opts = {
      -- open the file right away and do stuff like Treesitter/LSP lazily
      quickfile = { enabled = true },
      -- disable stuff like LSP and Treesitter from attaching if the file is massive
      bigfile = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    'stevearc/conform.nvim',
    -- load for all languages with an explicit config
    ft = vim.tbl_keys(require('my.ftconfig').config),
    -- also load on LSP attach because it has LSP fallback formatting
    event = 'LspAttach',
    opts = {
      formatters = {
        rustfmt = {
          options = {
            default_edition = '2024',
          },
        },
      },
      formatters_by_ft = formatters_by_ft,
      format_after_save = function()
        if not require('my.utils.lsp').is_formatting_enabled() then
          return
        end
        return { lsp_format = 'fallback' }
      end,
    },
  },
  {
    'mfussenegger/nvim-lint',
    ft = vim.tbl_keys(linters_by_ft),
    config = function()
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
        callback = function()
          require('lint').try_lint()
        end,
      })
      require('lint').linters_by_ft = linters_by_ft
    end,
  },
  {
    'SmiteshP/nvim-navbuddy',
    dependencies = {
      'SmiteshP/nvim-navic',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      lsp = { auto_attach = true },
      window = { sections = { right = { preview = 'always' } } },
    },
    keys = {
      {
        '<F4>',
        function()
          require('nvim-navbuddy').open()
        end,
        desc = 'Jump to symbol',
      },
    },
  },
  {
    'chrisgrieser/nvim-rulebook',
    dev = true,
    keys = {
      {
        '<leader>ri',
        function()
          require('rulebook').ignoreRule()
        end,
        desc = 'Add comment to ignore diagnostic error/warning rules',
      },
      {
        '<leader>rl',
        function()
          require('rulebook').lookupRule()
        end,
        desc = 'Look up rule documentation for error/warning diagnostics',
      },
    },
  },
  {
    'dnlhc/glance.nvim',
    -- for whatever reason, these options don't apply
    -- using `opts = {}`, so use `config` ¯\_(ツ)_/¯
    config = function()
      require('glance').setup({ ---@diagnostic disable-line: missing-fields
        border = { enable = false },
        theme = { enable = true, mode = 'darken' },
        mappings = {
          list = {
            ['<C-h>'] = function()
              require('glance').actions.enter_win('preview')()
            end,
          },
          preview = {
            ['<C-l>'] = function()
              require('glance').actions.enter_win('list')()
            end,
          },
        },
      })
    end,
  },
}
