return {
  'sourcegraph/sg.nvim',
  dependencies = { 'mrjones2014/op.nvim' },
  keys = {
    {
      '<leader>co',
      function()
        -- just load it to get cmp completions from cody
        require('sg')
      end,
      desc = 'Load sourcegraph.nvim plugin',
    },
  },
  config = function()
    local secret, stderr = require('op').get_secret('yz4q4rfnfzsvikdx4ppsze4tti', 'token,endpoint')
    if not secret then
      error(string.format('Failed to get Sourcegraph token from 1Password\n%s', stderr))
    end
    local secrets = vim.split(secret, ',')
    local token = secrets[1]
    local endpoint = secrets[2]
    vim.env.SRC_ENDPOINT = endpoint
    vim.env.SRC_ACCESS_TOKEN = token
    require('sg').setup({
      enable_cody = true,
    })
    local cmp = require('cmp')
    local config = cmp.get_config()
    table.insert(config.sources, { name = 'cody' })
  end,
}
