local formatters_by_ft = require('my.ftconfig').formatters_by_ft
local linters_by_ft = require('my.ftconfig').linters_by_ft
local lsp_util = require('my.utils.lsp')
lsp_util.on_attach(require('my.utils.lsp').on_attach_default)

-- enable all LSPs defined under lsp/
vim.lsp.enable(vim
  .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
  :map(function(f)
    return vim.fn.fnamemodify(f, ':t:r')
  end)
  :totable())

local function complete_client(arg)
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client)
      return client.name
    end)
    :filter(function(name)
      return name:sub(1, #arg) == arg
    end)
    :totable()
end

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd(string.format('tabnew %s', vim.lsp.log.get_filename()))
end, {
  desc = 'Opens the Nvim LSP client log.',
})

vim.api.nvim_create_user_command('LspRestart', function(info)
  local clients = info.fargs

  -- Default to restarting all active servers
  if #clients == 0 then
    clients = vim
      .iter(vim.lsp.get_clients())
      :map(function(client)
        return client.name
      end)
      :totable()
  end

  for _, name in ipairs(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid server name '%s'"):format(name))
    else
      vim.lsp.enable(name, false)
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for _, name in ipairs(clients) do
      vim.schedule_wrap(function(x)
        vim.lsp.enable(x)
      end)(name)
    end
  end)
end, {
  desc = 'Restart the given client',
  nargs = '?',
  complete = complete_client,
})

vim.api.nvim_create_user_command('LspInfo', ':checkhealth vim.lsp', { desc = 'Alias to `:checkhealth vim.lsp`' })

return {
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
    init = function()
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
    config = function()
      require('lint').linters_by_ft = linters_by_ft
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = { 'Bilal2453/luvit-meta' },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv', 'vim%.loop' } },
      },
    },
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
    'DNLHC/glance.nvim',
    event = 'LspAttach',
    config = function()
      local glance = require('glance')
      glance.setup({ ---@diagnostic disable-line:missing-fields
        border = {
          enable = true,
        },
        theme = {
          enable = true,
          mode = 'darken',
        },
        -- make win navigation mappings consistent with my default ones
        mappings = {
          list = {
            ['<C-h>'] = glance.actions.enter_win('preview'),
          },
          preview = {
            ['<C-l>'] = glance.actions.enter_win('list'),
          },
        },
      })
    end,
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
      require('glance').setup({
        border = { enable = false },
        theme = { mode = 'darken' },
        mappings = {
          list = {
            ['<C-h>'] = function()
              require('glance').actions.enter_win('preview')()
            end,
          },
          prview = {
            ['<C-l>'] = function()
              require('glance').actions.enter_win('list')()
            end,
          },
        },
      })
    end,
  },
  {
    -- otter is activated by ftplugins, see ftplugin/*
    'jmbuhr/otter.nvim',
    opts = {
      lsp = {
        root_dir = function(_, bufnr)
          return vim.fs.root(bufnr or 0, {
            '.git',
            'Cargo.lock',
            'package.json',
            'flake.nix',
          }) or vim.fn.getcwd(0)
        end,
      },
    },
  },
}
