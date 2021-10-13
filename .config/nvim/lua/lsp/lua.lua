local base_root = os.getenv('HOME') .. '/git/personal/lua-language-server'
local bin_root = base_root .. '/bin/macOS/'

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lspconfig').sumneko_lua.setup({
  cmd = { bin_root .. 'lua-language-server', '-E', base_root .. '/main.lua' },
  on_attach = require('modules.lsp-utils').on_attach,
  root_dir = require('lspconfig/util').root_pattern('.git', '.luacheckrc', 'stylua.toml'),
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
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
