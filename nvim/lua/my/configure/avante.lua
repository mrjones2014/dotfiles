local function register_lazy_op_secrets(secrets_map)
  local env_cache = {}
  local original_env = vim.env

  vim.env = setmetatable({}, {
    __index = function(_, key)
      if secrets_map[key] then
        if not env_cache[key] then
          local ref = secrets_map[key]
          local account = nil
          if type(ref) == 'table' then
            account = ref.account
            ref = ref.item
          end
          local secret, err = require('op').get_secret(ref, account)
          if secret then
            env_cache[key] = secret
          else
            vim.notify('Failed to get ' .. key .. ': ' .. (err or 'unknown error'), vim.log.levels.ERROR)
            return nil
          end
        end
        vim.fn.setenv(key, env_cache[key])
        return env_cache[key]
      else
        return original_env[key]
      end
    end,
    __newindex = function(_, key, value)
      original_env[key] = value
    end,
    __pairs = function()
      return pairs(original_env)
    end,
  })
end

-- Register the secrets we need
register_lazy_op_secrets({
  OPENAI_API_KEY = {
    item = 'op://3oblw6ndkgz2fgujm4jqq5jvfe/wvsh6k7w6t742vh3n3ghuevkqu/API Keys/Avante.nvim API Key',
    account = 'ZE3GMX56H5CV5J5IU5PLLFG4KQ',
  },
  SRC_ACCESS_TOKEN = {
    item = 'op://dvqle3hea253riyk5gatbxf3o4/dd46jdd5tvwm5uk375lm3pujwm/credential',
    account = 'S2EWWY7HCZDGFOQ7WOPBGAC2LY',
  },
})

local cody_models = {
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

local models = vim.tbl_deep_extend('force', cody_models, {
  ['openai-gpt5-mini'] = {
    __inherited_from = 'openai',
    model = 'gpt-5-mini-2025-08-07',
    api_key_name = 'OPENAI_API_KEY',
  },
})

local is_work_project = vim.trim(vim.system({ 'git', 'remote', 'get-url', 'origin' }):wait().stdout):find('1password')

return {
  'yetone/avante.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'brewinski/avante-cody.nvim',
      opts = { providers = cody_models },
    },
    {
      'Kaiser-Yang/blink-cmp-avante',
      dependencies = {
        {
          'saghen/blink.cmp',
          opts = function(_, opts)
            require('my.utils.completion').register_filetype_source(opts, 'AvanteInput', { 'avante' }, {
              avante = {
                name = 'Avante',
                module = 'blink-cmp-avante',
                -- show Avante commands first
                score_offset = 100,
              },
            })
          end,
        },
      },
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
    'AvanteToggle',
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- default provider
    provider = is_work_project and 'avante-cody-claude-sonnet' or 'openai-gpt5-mini',
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
