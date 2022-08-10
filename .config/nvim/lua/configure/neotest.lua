return {
  'nvim-neotest/neotest',
  requires = {
    'nvim-neotest/neotest-plenary',
    'haydenmeade/neotest-jest',
    'rouge8/neotest-rust',
  },
  config = function()
    require('neotest').setup({
      discovery = { enabled = false },
      adapters = {
        require('neotest-plenary'),
        require('neotest-rust'),
        require('neotest-jest')({
          jestCommand = 'pnpm jest',
          env = { CI = true },
          cwd = require('lsp.utils').typescript_root_dir,
        }),
      },
    })
  end,
}
