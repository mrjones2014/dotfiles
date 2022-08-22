return {
  'nvim-neotest/neotest',
  ft = require('my.lsp.filetypes').filetypes,
  requires = {
    'nvim-neotest/neotest-plenary',
    'haydenmeade/neotest-jest',
    'rouge8/neotest-rust',
  },
  config = function()
    require('neotest').setup({
      discovery = { enabled = false },
      diagnostic = { enabled = true },
      icons = {
        expanded = '',
        child_prefix = '',
        child_indent = '',
        final_child_prefix = '',
        non_collapsible = '',
        collapsed = '',

        passed = '',
        running = '',
        failed = '',
        unknown = '',
      },
      adapters = {
        require('neotest-plenary'),
        require('neotest-rust'),
        require('neotest-jest')({
          -- jestCommand = 'pnpm jest',
          env = { CI = true },
          cwd = function(path)
            return require('lspconfig.util').root_pattern('package.json', 'jest.config.js')(path)
          end,
        }),
      },
    })
  end,
}
