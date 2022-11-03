local M = {}

function M.setup()
  -- always load null-ls
  require('my.lsp.null-ls')

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspOnAttachCallback', { clear = true }),
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end

      require('my.lsp.utils').on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
    end,
  })

  -- lazy-load the rest of the configs with
  -- an autocommand that runs only once
  -- for each lsp config
  for filetype, filetype_config in pairs(require('my.lsp.filetypes').config) do
    local file_patterns = filetype_config.patterns
    local server_name = filetype_config.lspconfig
    if file_patterns and server_name then
      vim.api.nvim_create_autocmd('BufReadPre', {
        callback = function()
          local has_config, config = pcall(require, 'my.lsp.' .. filetype)
          config = has_config and config or {}
          config.capabilities =
            require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
          require('lspconfig')[server_name].setup(config)
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
end

return M
