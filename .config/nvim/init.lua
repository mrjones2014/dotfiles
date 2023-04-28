require('my.globals')
require('my.settings')
require('my.plugins')

local function is_manpager(cli_args)
  if vim.tbl_contains(cli_args, '+Man') or vim.tbl_contains(cli_args, '+Man!') then
    return true
  end

  local saw_cmd = false
  for _, arg in ipairs(cli_args) do
    if arg == '--cmd' or arg == '-c' then
      saw_cmd = true
    end

    if saw_cmd then
      if arg == 'Man' or arg == 'Man!' then
        return true
      end
    end
  end

  return false
end

local cli_args = vim.v.argv
if (#cli_args == 1 or (#cli_args == 2 and cli_args[2] == '--embed')) and not is_manpager(cli_args) then
  require('my.startup').show()
end
