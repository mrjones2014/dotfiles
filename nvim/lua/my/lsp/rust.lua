return {
  before_init = function(_, config)
    -- Override clippy to run in its own directory to avoid clobbering caches
    -- but only if target-dir isn't already set in either the command or the extraArgs
    local checkOnSave = config.settings['rust-analyzer'].checkOnSave
    local needle = '--target-dir'
    if string.find(checkOnSave.command, needle, nil, true) then
      return
    end

    checkOnSave.extraArgs = checkOnSave.extraArgs or {}
    for _, v in pairs(checkOnSave.extraArgs or {}) do
      if string.find(v, needle, nil, true) then
        return
      end
    end

    local target_dir = config.root_dir .. '/target/ide-clippy'
    table.insert(checkOnSave.extraArgs, '--target-dir=' .. target_dir)
  end,
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureReturnTypeHints = { enable = 'always' },
        discriminantHints = { enable = 'always' },
        parameterHints = { enable = true },
      },
      diagnostics = {
        disabled = { 'inactive-code', 'unresolved-proc-macro' },
      },
      procMacro = { enable = true },
      files = {
        excludeDirs = {
          '.direnv',
          'target',
          'js',
          'node_modules',
          'assets',
          'ci',
          'data',
          'docs',
          'store-metadata',
          '.gitlab',
          '.vscode',
          '.git',
        },
      },
    },
  },
}
