local clipboard = require('my.utils.clipboard')
return {
  {
    'folke/snacks.nvim',
    keys = {
      {
        '<leader>gy',
        function()
          clipboard.copy(require('snacks.gitbrowse').get_url())
        end,
        desc = 'Copy git permalink',
        silent = true,
      },
    },
    opts = {
      gitbrowse = {
        what = 'permalink',
        url_patterns = {
          ['gitlab%.1password%.io'] = {
            branch = '/-/tree/{branch}',
            file = '/-/blob/{branch}/{file}#L{line_start}-L{line_end}',
            permalink = '/-/blob/{commit}/{file}#L{line_start}-L{line_end}',
            commit = '/-/commit/{commit}',
          },
        },
      },
    },
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
}
