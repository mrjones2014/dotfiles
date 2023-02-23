return {
  before_init = function(_, config)
    -- Override clippy to run in its own directory to avoid clobbering caches
    -- but only if target-dir isn't already set in either the command or the extraArgs
    local checkOnSave = config.settings['rust-analyzer'].checkOnSave
    local needle = '%-%-target%-dir'
    if string.find(checkOnSave.command, needle) then
      return
    end

    local extraArgs = checkOnSave.extraArgs
    for _, v in pairs(extraArgs) do
      if string.find(v, needle) then
        return
      end
    end

    local target_dir = config.root_dir .. '/target/ide-clippy'
    table.insert(extraArgs, '--target-dir=' .. target_dir)
  end,
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      check = {
        extraArgs = {
          '--',
          '--warn=clippy::dbg_macro',
          '--warn=clippy::unimplemented',
          '--warn=clippy::todo',
          '--warn=missing_docs',
          '--deny=broken_intra_doc_links',
          '--deny=clippy::undocumented_unsafe_blocks',
          '--forbid=unused_must_use',
          '--deny=clippy::as_conversions',
          '--deny=clippy::result_unit_err',
        },
      },
      diagnostics = {
        disabled = { 'inactive-code' },
      },
      procMacro = { enable = true },
      files = {
        excludeDirs = {
          './js/',
          './node_modules/',
          './assets/',
          './ci/',
          './data/',
          './docs/',
          './store-metadata/',
          './.gitlab/',
          './.vscode/',
          './.git/',
        },
      },
    },
  },
}
