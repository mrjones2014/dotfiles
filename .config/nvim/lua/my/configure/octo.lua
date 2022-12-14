return {
  'pwntester/octo.nvim',
  event = 'User DashboardLeave',
  cmd = 'Octo',
  config = function()
    require('octo').setup({
      gh_env = function()
        local github_token = require('op.api').item.get({ 'GitHub', '--fields', 'token' })[1]
        if not github_token or not vim.startswith(github_token, 'ghp_') then
          error('Failed to get GitHub token.')
        end

        return { GITHUB_TOKEN = github_token }
      end,
    })
  end,
}
