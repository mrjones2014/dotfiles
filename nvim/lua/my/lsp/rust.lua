return {
  settings = {
    ['rust-analyzer'] = {
      rust = {
        analyzerTargetDir = true,
      },
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
          'brain/op-navi/data',
          'node_modules',
          'ffi/op-core-wasm-web/node_modules',
          'ffi/op-wasm-trusted-device-key-exchange/node_modules',
          'ffi/op-web-core-bindings/node_modules',
          'ffi/op-core-bindings/node_modules',
          'ffi/op-core-node/node_modules',
        },
      },
    },
  },
}
