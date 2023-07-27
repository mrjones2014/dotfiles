-- TODO this one doesn't work
local fs = require('efmls-configs.fs')
local linter = fs.executable('statix')
local command = string.format('%s check --stdin --format=errfmt', linter)
return {
  lintCommand = command,
  lintStdin = true,
  -- lintIgnoreExitCode = true,
  lintFormats = { '<text>%l:%c:%t:<text>:%m' },
  rootMarkers = {
    'flake.nix',
    'shell.nix',
    'default.nix',
  },
}
