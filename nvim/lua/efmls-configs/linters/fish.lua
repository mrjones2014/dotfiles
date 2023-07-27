-- TODO this isn't working
local fs = require('efmls-configs.fs')
local linter = fs.executable('fish')
local command = string.format('%s --no-execute ${INPUT}', linter)

return {
  lintCommand = command,
  lintIgnoreExitCode = true,
  lintStdin = false,
  lintFormats = { '%f (line %l): %m' },
}
