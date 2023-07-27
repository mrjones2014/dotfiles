local fs = require('efmls-configs.fs')
local formatter = fs.executable('rustfmt')
local command = string.format('%s --emit=stdout', formatter)
return {
  formatCommand = command,
  formatStdin = true,
}
