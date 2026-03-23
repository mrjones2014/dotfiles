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
        return {}
      end
      return {
        GITHUB_TOKEN = secret,
      }
    end,
  },
}
