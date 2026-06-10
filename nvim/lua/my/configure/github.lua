local vcs = require('my.utils.vcs')

local is_jj_gh = vim.env.JJ_GH == '1'
local is_work_repo = vcs.is_work_repo()

local _cached_gh_token = nil
local function get_github_token()
  if _cached_gh_token ~= nil then
    return _cached_gh_token
  end

  if vcs.is_work_repo() then
    -- work uses OAuth tokens now
    return nil
  end

  local account = '3UBYV6PWJZAS7HTEKHDSQ7HPUA'
  local ref = 'op://Private/GitHub/token'
  local secret, stderr = require('op').get_secret(ref, account)
  if stderr then
    vim.notify('Failed to get GitHub token from 1Password: ' .. stderr, vim.log.levels.ERROR)
    return nil
  end
  _cached_gh_token = secret
  return secret
end

return {
  {
    'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
      'mrjones2014/op.nvim',
    },
    cmd = 'Octo',
    keys = {
      {
        '<leader>pr',
        '<CMD>Octo pr list<CR>',
        desc = 'List GitHub PullRequests',
      },
      {
        '<leader>ps',
        function()
          require('octo.utils').create_base_search_command({ include_current_repo = true })
        end,
        desc = 'Search GitHub',
      },
    },
    opts = {
      picker = 'snacks',
      enable_builtin = true,
      ssh_aliases = { ['github-enterprise'] = 'github.com' },
      gh_env = is_work_repo and {} or function()
        return { GITHUB_TOKEN = get_github_token() }
      end,
    },
  },
  {
    'Kaiser-Yang/blink-cmp-git',
    ---@module 'blink-cmp-git'
    ---@type blink-cmp-git.Options
    dependencies = {
      'saghen/blink.cmp',
      ---@module 'blink-cmp'
      ---@type blink.cmp.Config
      opts = {
        sources = {
          per_filetype = {
            markdown = { inherit_defaults = true, 'git' },
          },
          providers = {
            git = {
              module = 'blink-cmp-git',
              name = 'Git',
              enabled = function()
                return is_jj_gh
              end,
              ---@module 'blink-cmp-git'
              ---@type blink-cmp-git.Options
              opts = {
                commit = { enable = false },
                git_centers = {
                  github = {
                    pull_request = { enable = false },
                    issue = {
                      enable = function()
                        return is_jj_gh
                      end,
                      get_token = (not is_work_repo) and get_github_token or nil,
                      get_command = (not is_work_repo) and 'curl' or nil,
                    },
                    mention = {
                      enable = function()
                        return is_jj_gh
                      end,
                      get_token = (not is_work_repo) and get_github_token or nil,
                      get_command = (not is_work_repo) and 'curl' or nil,
                      get_command_args = function(command, token)
                        -- increase default page size
                        local args = require('blink-cmp-git.default.github').mention.get_command_args(command, token)
                        local utils = require('blink-cmp-git.utils')
                        args[#args] = 'https://api.github.com/repos/'
                          .. utils.get_repo_owner_and_repo()
                          .. '/contributors?per_page=100'
                        return args
                      end,
                      get_documentation = function(item)
                        local default = require('blink-cmp-git.default.github').mention.get_documentation(item)
                        default.get_token = (not is_work_repo) and get_github_token or default.get_token
                        default.get_command = (not is_work_repo) and 'curl' or default.get_command
                        return default
                      end,
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}
