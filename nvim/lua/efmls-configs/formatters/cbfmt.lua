-- TODO this one isn't working
local fs = require('efmls-configs.fs')
local formatter = fs.executable('cbfmt')
local command = string.format('%s --stdin-filepath ${INPUT} --best-effort', formatter)

return {
  formatCommand = command,
  formatStdin = true,
}
