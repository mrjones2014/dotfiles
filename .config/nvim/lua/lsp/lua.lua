local version = vim.env.LUA_LSP_VERSION
local base_root = '/opt/homebrew/Cellar/lua-language-server/' .. version
local bin_root = base_root .. '/bin/'

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

local globals = { 'vim' }
if string.find(vim.loop.cwd(), 'hammerspoon') then
  globals = { 'hs' }
end

require('lspconfig').sumneko_lua.setup({
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  cmd = { bin_root .. 'lua-language-server', '-E', base_root .. '/libexec/main.lua' },
  on_attach = require('lsp.utils').on_attach,
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
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})
