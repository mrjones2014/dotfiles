return {
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = 'clippy',
      },
      diagnostics = {
        disabled = { 'inactive-code' },
      },
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
