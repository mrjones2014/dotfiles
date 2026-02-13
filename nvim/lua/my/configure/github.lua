return {
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
      -- use 1Password to get GitHub token, check git remote
      -- to figure out which token we should use
      local account = 'ZE3GMX56H5CV5J5IU5PLLFG4KQ'
      local ref = 'op://Private/GitHub/token'
      local vcs = require('my.utils.vcs')
      if vcs.is_work_repo() then
        account = 'S2EWWY7HCZDGFOQ7WOPBGAC2LY'
        ref = 'op://Employee/1Password GitHub Token/credential'
      end
      local secret, stderr = require('op').get_secret(ref, account)
      if stderr then
        vim.notify('Failed to get GitHub token from 1Password: ' .. stderr, vim.log.levels.ERROR)
        return {}
      end
      return {
        GITHUB_TOKEN = secret,
      }
    end,
  },
}
