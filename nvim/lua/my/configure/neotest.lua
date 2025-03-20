local cmds = {
  {
    'Test',
    function()
      require('neotest').run.run()
    end,
    {
      desc = 'Run nearest test',
    },
  },
  {
    'TestFile',
    function()
      require('neotest').run.run(vim.fn.expand('%'))
    end,
    { desc = 'Run tests in current file' },
  },
  {
    'TestStop',
    function()
      require('neotest').run.stop()
    end,
    { desc = 'Kill running tests' },
  },
  {
    'TestOpen',
    function()
      require('neotest').output.open()
    end,
    { desc = 'Open test output' },
  },
  {
    'TestSummary',
    function()
      require('neotest').summary.open()
    end,
    { desc = 'Open test summary' },
  },
}

return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-go',
    'nvim-neotest/neotest-jest',
    'mrcjkb/rustaceanvim',
  },
  cmds = vim
    .iter(cmds)
    :map(function(cmd)
      return cmd[1]
    end)
    :totable(),
  init = function()
    for _, cmd in ipairs(cmds) do
      vim.api.nvim_create_user_command(cmd[1], cmd[2], cmd[3])
    end
  end,
  config = function()
    ---@diagnostic disable: missing-fields
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
