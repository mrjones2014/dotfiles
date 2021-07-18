require('lspconfig').jsonls.setup({
  on_attach = require('lsp/utils').on_attach,
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line('$'),0})
      end
    }
  }
})
