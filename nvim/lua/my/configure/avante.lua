local models = {
  ['avante-cody-claude-sonnet'] = {
    endpoint = 'https://1password.sourcegraphcloud.com',
    api_key_name = 'SRC_ACCESS_TOKEN',
    model = 'anthropic::2024-10-22::claude-sonnet-4-latest',
  },
  ['avante-cody-claude-opus'] = {
    model = 'anthropic::2024-10-22::claude-opus-4-thinking-latest',
    endpoint = 'https://1password.sourcegraphcloud.com',
    api_key_name = 'SRC_ACCESS_TOKEN',
  },
}

return {
  'yetone/avante.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'brewinski/avante-cody.nvim',
      config = function()
        local secret, err = require('op.api').read({
          'op://Employee/SourceGraph API Token/credential',
          '--account',
          'S2EWWY7HCZDGFOQ7WOPBGAC2LY',
        })
        if secret ~= nil and #secret > 0 then
          vim.env.SRC_ACCESS_TOKEN = secret[1]
        elseif err ~= nil then
          vim.notify(err, vim.log.levels.ERROR)
          error(err)
        end
        require('avante-cody').setup({ providers = models })
      end,
    },
  },
  build = 'make',
  version = false,
  cmd = {
    'AvanteAsk',
    'AvanteBuild',
    'AvanteChat',
    'AvanteChatNew',
    'AvanteClear',
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- default provider
    provider = 'avante-cody-claude-opus',
    providers = models,
    -- Recommended settings to avoid rate limits
    mode = 'legacy',
    disabled_tools = {
      'insert',
      'create',
      'str_replace',
      'replace_in_file',
    },
  },
}
