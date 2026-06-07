local is_jj_gh = vim.env.JJ_GH == '1'

local _cached_gh_token = nil
local function get_github_token()
  if _cached_gh_token ~= nil then
    return _cached_gh_token
  end
  -- use 1Password to get GitHub token, check git remote
  -- to figure out which token we should use
  local account = '3UBYV6PWJZAS7HTEKHDSQ7HPUA'
  local ref = 'op://Private/GitHub/token'
  local vcs = require('my.utils.vcs')
  if vcs.is_work_repo() then
    account = 'AKHM3DPGNZFUJOY7N4UAWAMLIE'
    ref = 'op://Employee/1Password GitHub Token/credential'
  end
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
      gh_env = function()
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
                      get_token = get_github_token,
                      get_command = 'curl',
                    },
                    mention = {
                      enable = function()
                        return is_jj_gh
                      end,
                      get_token = get_github_token,
                      get_command = 'curl',
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
                        default.get_token = get_github_token
                        default.get_command = 'curl'
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
