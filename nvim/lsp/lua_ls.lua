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
  ---@type lsp.lua_ls
  settings = {
    Lua = {
      completion = {
        autoRequire = true,
      },
      runtime = {
        version = 'LuaJIT',
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
          '?/lua/?.lua',
          '?/lua/?/init.lua',
          '?/?.lua',
          '?/init.lua',
        },
        pathStrict = false,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.list_extend({ '${3rd}/luv/library' }, vim.api.nvim_list_runtime_paths()),
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
