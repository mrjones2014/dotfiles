return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-go',
    'nvim-neotest/neotest-jest',
    'mrcjkb/rustaceanvim',
  },
  config = function()
    require('neotest').setup({
      discovery = { enabled = false },
      diagnostic = { enabled = true },
      status = { enabled = true },
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
        require('rustaceanvim.neotest'),
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
