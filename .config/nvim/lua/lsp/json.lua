local utils = require('lspconfig/util')

require('lspconfig').jsonls.setup({
  on_attach = require('lsp/utils').on_attach,
  root_dir = utils.root_pattern('.git'),
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line('$'),0})
      end
    }
  }
})
