local M = {}

function M.setup()
  -- always load null-ls
  require('my.lsp.null-ls')

  -- lazy-load the rest of the configs with
  -- an autocommand that runs only once
  -- for each lsp config
  for filetype, file_patterns in pairs(require('my.lsp.filetypes').filetype_patterns) do
    vim.api.nvim_create_autocmd('BufReadPre', {
      callback = function()
        local has_config, config = pcall(require, 'my.lsp.' .. filetype)
        config = has_config and config or {}
        config.capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
        config.on_attach = require('my.lsp.utils').on_attach
        local server = require('my.lsp.filetypes').servers[filetype]
        require('lspconfig')[server].setup(config)
        local snippets = require('my.lsp.snippets')[filetype]
        if snippets then
          snippets()
        end
      end,
      pattern = file_patterns,
      once = true,
    })
  end
end

return M
