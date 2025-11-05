local path = require('my.utils.path')

local ripgrep_ignore_file_path = (
  path.join(vim.env.XDG_CONFIG_HOME or path.join(vim.env.HOME, '.config'), 'ripgrep_ignore')
)

local function pick(which, opts)
  return function()
    if vim.startswith(which, 'gh_') and vim.env.GH_TOKEN == nil then
      local token = require('op').get_secret('op://Private/GitHub/token', 'ZE3GMX56H5CV5J5IU5PLLFG4KQ')
      if not token then
        error('GitHub token not found in 1Password')
      end
      vim.uv.os_setenv('GH_TOKEN', token)
    end
    return require('snacks.picker')[which](opts)
  end
end

return {
  'folke/snacks.nvim',
  keys = {
    { 'ff', pick('smart', { hidden = true }), desc = 'Find files' },
    { 'fh', pick('recent'), desc = 'Find oldfiles' },
    { 'fb', pick('buffers'), desc = 'Find buffers' },
    { 'ft', pick('grep', { hidden = true }), desc = 'Find text' },
    { 'fs', pick('lsp_workspace_symbols'), desc = 'Find LSP symbols in the workspace' },
    { 'fr', pick('resume'), desc = 'Resume last finder' },
    {
      'fi',
      pick('icons', { icon_sources = { 'nerd_fonts' }, confirm = { 'copy', 'close' } }),
      desc = 'Find nerdfont icons',
    },
    { 'fgi', pick('gh_issue'), desc = 'Find GitHub issues' },
    { 'fgp', pick('gh_pr'), desc = 'Find GitHub pull requests' },
  },
  opts = {
    styles = {
      input = {
        relative = 'cursor',
      },
    },
    input = { enabled = true },
    image = { enabled = true },
    picker = {
      layout = {
        preset = 'telescope',
      },
      sources = {
        files = { args = { '--ignore-file', ripgrep_ignore_file_path } },
        grep = { args = { '--ignore-file', ripgrep_ignore_file_path } },
        recent = {
          filter = {
            paths = {
              [vim.uv.cwd()] = true,
              [string.format('%s/.git/COMMIT_EDITMSG', vim.uv.cwd())] = false,
            },
          },
        },
      },
      actions = {
        trouble_open = {
          action = function(picker)
            require('trouble.sources.snacks').open(picker, {})
          end,
          description = 'smart-open-with-trouble',
        },
      },
      win = {
        input = {
          keys = {
            -- fully close picker on `ESC`, I use `jk` to go to normal mode
            ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
            -- keep `<C-u>` to clear prompt
            ['<C-u>'] = false,
            ['<C-t>'] = {
              'trouble_open',
              mode = { 'n', 'i' },
            },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true,
          truncate = 85,
        },
      },
    },
  },
  dependencies = {
    {
      'folke/trouble.nvim',
      cmd = 'Trouble',
      keys = {
        { '<leader>d', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Toggle diagnostics list' },
        { '<leader>q', '<cmd>Trouble qflist toggle<cr>', desc = 'Toggle quickfix list' },
        { '<leader>l', '<cmd>Trouble symbols toggle win.position=right<cr>', desc = 'Show LSP symbol tree' },
      },
      opts = { action_keys = { hover = {} } },
    },
    {
      'kevinhwang91/nvim-bqf',
      ft = 'qf', -- load on quickfix list opened,
      opts = {
        func_map = {
          pscrolldown = '<C-d>',
          pscrollup = '<C-f>',
        },
      },
    },
  },
}
