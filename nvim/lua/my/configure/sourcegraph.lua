return {
  'sourcegraph/sg.nvim',
  dependencies = { 'mrjones2014/op.nvim' },
  config = function()
    local op = require('op.api') ---@type OpApi
    local stdout, stderr, exit_code = op.item.get({ 'yz4q4rfnfzsvikdx4ppsze4tti', '--format', 'json' })
    if exit_code ~= 0 then
      error(string.format('Failed to get Sourcegraph token from 1Password\n%s', table.concat(stderr, '\n')))
    end
    local item = vim.json.decode(table.concat(stdout, ''))
    local token = vim.iter(item.fields):find(function(field)
      return field.label == 'token'
    end)
    if not token then
      error('Failed to get Sourcegraph token from 1Password')
    end
    token = token.value
    vim.env.SRC_ENDPOINT = item.urls[1].href
    vim.env.SRC_ACCESS_TOKEN = token
    require('sg').setup({
      enable_cody = false,
    })
  end,
}
