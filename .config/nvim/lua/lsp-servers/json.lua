require('lspconfig').jsonls.setup({
  on_attach = require('lsp-servers/utils').on_attach,
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line('$'),0})
      end
    }
  }
})
