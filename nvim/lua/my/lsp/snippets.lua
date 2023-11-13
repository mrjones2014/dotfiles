local M = {}

local LUA_MODULE_RETURN_TS_QUERY = [[
(return_statement
	(expression_list
		(identifier) @return-value-name))
]]

function M.lua()
  local ls = require('luasnip')
  local s = ls.s
  local i = ls.insert_node
  local f = ls.function_node
  local fmt = require('luasnip.extras.fmt').fmt
  local p = ls.parser.parse_snippet
  local c = ls.choice_node

  local function get_returned_mod_name()
    local query = vim.treesitter.query.parse('lua', LUA_MODULE_RETURN_TS_QUERY)
    local parser = vim.treesitter.get_parser(0, 'lua')
    local tree = parser:parse()[1]
    local num_lines = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for _, node, _ in query:iter_captures(tree:root(), 0, num_lines - 3, num_lines) do
      return vim.treesitter.get_node_text(node, 0, {})
    end
  end

  local function get_req_module(req_path)
    local parts = vim.split(req_path[1][1], '%.', { trimempty = true })
    return parts[#parts] or ''
  end

  local function get_req_module_upper(req_path)
    local path = get_req_module(req_path)
    return path:sub(1, 1):upper() .. path:sub(2)
  end

  ls.add_snippets('lua', {
    -- type req, type the module path, and the `local {}` will be automatically
    -- filled in as the last section of the module path, e.g. `require('my.custom.mod)` => `local mod`
    -- the `local` part is also a choice node allowing you to toggle between `local mod` and `local Mod`
    s(
      'req',
      fmt("local {} = require('{}')", {
        c(2, {
          f(get_req_module, { 1 }),
          f(get_req_module_upper, { 1 }),
        }),
        i(1),
      })
    ),
    -- create a new function on the module, dynamically using the `local` that is
    -- returned from the overall module, e.g.
    -- local MyMod =  {}
    -- ...
    -- return MyMod
    -- in this case it will use `function MyMod.fn_name()`
    s(
      'mfn',
      c(1, {
        fmt('function {}.{}({})\n  {}\nend', {
          f(get_returned_mod_name, {}),
          i(1),
          i(2),
          i(3),
        }),
        fmt('function {}:{}({})\n  {}\nend', {
          f(get_returned_mod_name, {}),
          i(1),
          i(2),
          i(3),
        }),
      })
    ),
    -- create a module structure, allowing you to customize the module name
    p('mod', 'local $1 = {}\n\n$0\n\nreturn $1', {}),
    -- require without assigning to a local
    p('rq', "require('$0')", {}),
    -- inline global function
    p('fn', 'function($1)\n  $0\nend', {}),
    -- inline local function
    p('lfn', 'local function $1($2)\n  $0\nend', {}),
  })
end

-- since these snippets are shared between 4 filetypes,
-- ensure we're only registering them once
local ts_snippets_added = false
function M.typescript()
  if ts_snippets_added then
    return
  end

  local ls = require('luasnip')
  local p = ls.parser.parse_snippet

  local snippets = {
    p('fn', 'function $1($2)$3 {\n  $0\n}', {}),
    p('afn', 'const $1 = ($2)$3 => {\n  $0\n}', {}),
    p('ifn', '($1)$2 => {\n  $0\n}', {}),
  }

  ls.add_snippets('typescript', snippets)
  ls.add_snippets('typescriptreact', snippets)
  ls.add_snippets('javascript', snippets)
  ls.add_snippets('javascriptreact', snippets)

  ts_snippets_added = true
end
M.typescriptreact = M.typescript
M.javascript = M.typescript
M.javascriptreact = M.typescript

function M.rust()
  local ls = require('luasnip')
  local p = ls.parser.parse_snippet
  ls.add_snippets('rust', {
    p('deny', '#![deny(clippy::all, clippy::pedantic, rust_2018_idioms, clippy::unwrap_used)]\n\n', {}),
    p('fn', 'fn $1($2)$3 {\n  $0\n}', {}),
    p('res', 'Result<$1, $2>$0', {}),
    p('opt', 'Option<$1>$0', {}),
    p('const', 'const $1: $2 = $0;', {}),
    p('enum', '#[derive(Debug)]\nenum $1 {\n  $0\n}', {}),
    p('derive', '#[derive($0)]', {}),
    p('tst', '#[test]', {}),
    p('impl', 'impl $1 {\n  $0\n}', {}),
    p('for', 'for $1 in $2 {\n  $0\n}', {}),
    p('ifl', 'if let Some($1) = $1 {\n  $0\n}', {}),
  })
end

return M
