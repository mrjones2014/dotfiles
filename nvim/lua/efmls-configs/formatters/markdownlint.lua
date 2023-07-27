-- TODO file isn't reloaded after formatting
local fs = require('efmls-configs.fs')
local formatter = fs.executable('markdownlint')
local command = string.format('%s --fix ${INPUT}', formatter)
return {
  formatCommand = command,
  formatStdin = false,
}
