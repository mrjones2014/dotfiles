local DEFAULT_PROVIDER = 'claude_code'

local function hostname()
  return vim.fn.hostname()
end

local function is_work_computer()
  return hostname() == 'corpo'
end

local function is_server()
  return hostname() == 'mikoshi'
end

local function is_floating_window(win)
  local cfg = vim.api.nvim_win_get_config(win or 0)
  return cfg and (cfg.relative ~= '' or not cfg.relative)
end

local _claude_code

---@type LazySpec
return {
  { import = 'astrocommunity.ai.codecompanion-nvim' },
  {
    'mrjones2014/codecompanion-ui.nvim',
    dev = true,
    lazy = true,
  },
  {
    'AstroNvim/astrocore',
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        -- codecompanion-ui already sets number=false / signcolumn=no on its windows,
        -- but AstroNvim renders a heirline `statuscolumn` globally, which keeps drawing
        -- the number/sign/fold columns anyway. Clear it for these buffers.
        codecompanion_clean_gutter = {
          {
            event = 'FileType',
            pattern = { 'codecompanion', 'codecompanion_input' },
            desc = 'Hide the gutter in CodeCompanion windows',
            callback = function()
              vim.wo[0][0].statuscolumn = ''
              vim.wo[0][0].number = false
              vim.wo[0][0].relativenumber = false
              vim.wo[0][0].signcolumn = 'no'
              vim.wo[0][0].foldcolumn = '0'
            end,
          },
          {
            event = 'BufWinEnter',
            desc = 'Re-apply when a CodeCompanion buffer lands in a new window',
            callback = function(args)
              if vim.bo[args.buf].filetype:match('^codecompanion') then
                vim.wo[0][0].statuscolumn = ''
                vim.wo[0][0].number = false
                vim.wo[0][0].relativenumber = false
                vim.wo[0][0].signcolumn = 'no'
                vim.wo[0][0].foldcolumn = '0'
              end
            end,
          },
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    enabled = not is_server(),
    dependencies = {
      'folke/snacks.nvim',
      'mrjones2014/codecompanion-ui.nvim',
      'mrjones2014/op.nvim',
    },
    cmd = { 'CodeCompanionClear' },
    keys = {
      {
        '<leader>Af',
        function()
          if require('codecompanion-ui').is_visible() then
            require('codecompanion-ui').focus_input()
          else
            -- fallback: find any non-floating CodeCompanion window
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == 'codecompanion' and not is_floating_window(win) then
                vim.api.nvim_set_current_win(win)
                break
              end
            end
          end
        end,
        desc = 'Focus Codecompanion window',
      },
      {
        '<leader>An',
        function()
          require('codecompanion').chat()
        end,
        desc = 'New session',
      },
    },
    opts = {
      opts = {
        log_level = 'DEBUG',
      },
      rules = {
        -- don't load rules by default, the Claude Code ACP adapter loads its own
        default = {
          files = {},
          is_default = false,
        },
      },
      adapters = {
        acp = {
          claude_code = function()
            if _claude_code ~= nil then
              return _claude_code
            end

            local ok, op = pcall(require, 'op')
            if not ok then
              error('op.nvim is not installed, claude_code adapter will not work', vim.log.levels.ERROR)
            end
            local token = is_work_computer()
                and assert(
                  op.get_secret('op://Employee/1Password Claude Token/password', 'AKHM3DPGNZFUJOY7N4UAWAMLIE'),
                  'Failed to retrieve 1Password Claude Token'
                )
              or assert(
                op.get_secret('op://Private/Claude/token', '3UBYV6PWJZAS7HTEKHDSQ7HPUA'),
                'Failed to retrieve personal Claude token'
              )
            _claude_code = require('codecompanion.adapters').extend('claude_code', {
              defaults = { mode = 'plan', model = is_work_computer() and 'opus[1m]' or 'opus' },
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = token,
              },
            })
            return _claude_code
          end,
        },
        http = {
          local_ollama = function()
            return require('codecompanion.adapters').extend('ollama', {
              env = {
                url = vim.env.OLLAMA_SERVER_ADDRESS,
              },
              schema = {
                model = {
                  default = vim.env.OLLAMA_DEFAULT_MODEL,
                },
              },
            })
          end,
        },
      },
      extensions = {
        ui = { enabled = true },
      },
      interactions = {
        cmd = { adapter = DEFAULT_PROVIDER },
        background = {
          adapter = 'local_ollama',
          chat = {
            opts = { enabled = true },
            callbacks = {
              on_ready = {
                enabled = true,
                actions = {
                  'interactions.background.builtin.chat_make_title',
                },
              },
            },
          },
        },
        chat = {
          adapter = DEFAULT_PROVIDER,
          keymaps = {
            -- remapped because I use gx to open URLs
            clear = {
              modes = { n = 'gX' },
            },
          },
        },
      },
    },
  },
}
