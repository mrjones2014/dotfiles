local runtime_path = vim.split(package.path, ';', {})
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  ---@module 'codesettings'
  ---@type lsp.lua_ls
  settings = {
    Lua = {
      completion = {
        autoRequire = false,
      },
      runtime = {
        version = 'LuaJIT',
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
          'lua/?/?.lua',
          'plugin/?.lua',
          'ftplugin/?.lua',
        },
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          vim.env.VIMRUNTIME,
        },
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
