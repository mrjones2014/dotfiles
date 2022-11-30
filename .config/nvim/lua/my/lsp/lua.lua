local runtime_path = vim.split(package.path, ';', {})
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

local globals = { 'vim' }
if string.find(assert(vim.loop.cwd()), 'hammerspoon') then
  globals = { 'hs' }
end

return {
  root_dir = require('lspconfig.util').root_pattern('.git', '.luacheckrc', 'stylua.toml'),
  settings = {
    Lua = {
      completion = {
        autoRequire = false,
      },
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = globals,
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
        -- disable annoying "do you need to configure your workspace as luassert" prompts
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
