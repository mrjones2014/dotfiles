return {
  'nvim-neotest/neotest',
  requires = {
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-go',
    'haydenmeade/neotest-jest',
    'rouge8/neotest-rust',
  },
  ft = {
    'lua',
    'go',
    'rust',
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
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
      summary = {
        mappings = {
          jumpto = '<CR>',
          expand = { '<Space>', '<2-LeftMouse>' },
        },
      },
      adapters = {
        require('neotest-plenary'),
        require('neotest-go'),
        require('neotest-rust'),
        require('neotest-jest')({
          jestCommand = 'pnpm jest',
          env = { CI = true },
          cwd = function(path)
            return require('lspconfig.util').root_pattern('package.json', 'jest.config.js')(path)
          end,
        }),
      },
    })
  end,
}
