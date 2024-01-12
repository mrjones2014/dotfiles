return {
  'sourcegraph/sg.nvim',
  dependencies = { 'mrjones2014/op.nvim' },
  config = function()
    local output = require('op').get_secret('yz4q4rfnfzsvikdx4ppsze4tti', 'token,endpoint')
    if output then
      error('Failed to get Sourcegraph token from 1Password')
    end
    local secrets = vim.split(output, ',')
    local token = secrets[1]
    local endpoint = secrets[2]
    vim.env.SRC_ENDPOINT = endpoint
    vim.env.SRC_ACCESS_TOKEN = token
    require('sg').setup({
      enable_cody = false,
    })
  end,
}
