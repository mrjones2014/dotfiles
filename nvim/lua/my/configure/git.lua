local clipboard = require('my.utils.clipboard')
return {
  {
    'linrongbin16/gitlinker.nvim',
    cmd = { 'GitLink' },
    opts = {
      action_callback = clipboard.copy,
      router = {
        browse = {
          ['gitlab%.1password%.io'] = function(data)
            local url = string.format(
              'https://gitlab.1password.io/%s/%s/-/blob/%s/%s',
              data.org,
              data.repo:gsub('%.git', ''),
              data.current_branch,
              data.file
            )
            clipboard.copy(url)
            return url
          end,
          ['^github%.com'] = function(data)
            local url = string.format(
              'https://github.com/%s/%s/blob/%s/%s',
              data.org,
              data.repo:gsub('%.git', ''),
              data.current_branch,
              data.file
            )
            clipboard.copy(url)
            return url
          end,
        },
      },
    },
    keys = { { '<leader>gy', '<cmd>GitLink<cr>', desc = 'Copy GitHub link', silent = true } },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      -- see also: autocmds.lua
      -- this gets toggled off in insert mode
      -- and back on when leaving insert mode
      signcolumn = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 100,
      },
      current_line_blame_formatter = ' <abbrev_sha> | <author>, <author_time> - <summary>',
      on_attach = function()
        vim.cmd.redrawstatus()
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewRefresh',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        file_panel = {
          win_config = {
            position = 'right',
          },
        },
      },
    },
  },
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    opts = {
      gh_env = function()
        local github_token = require('op').get_secret('GitHub', 'token')
        if not github_token or not vim.startswith(github_token, 'ghp_') then
          error('Failed to get GitHub token.')
        end

        return { GITHUB_TOKEN = github_token }
      end,
    },
  },
  {
    'moyiz/dit-dev.nvim',
    cmd = { 'GitDevOpen', 'GitDevCleanAll' },
    opts = {},
  },
}
