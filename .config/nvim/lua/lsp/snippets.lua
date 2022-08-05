local M = {}

function M.lua()
  local ls = require('luasnip')
  local s = ls.s
  local i = ls.insert_node
  local f = ls.function_node
  local fmt = require('luasnip.extras.fmt').fmt
  local p = ls.parser.parse_snippet

  ls.add_snippets('lua', {
    s(
      'req',
      fmt("local {} = require('{}')", {
        f(function(req_path)
          local parts = vim.split(req_path[1][1], '.', true)
          return parts[#parts] or ''
        end, {
          1,
        }),
        i(1),
      })
    ),
    p('rq', "require('$0')"),
    p('fn', 'function($1)\n  $0\nend'),
    p('mfn', 'function M.$1($2)\n  $0\nend'),
    p('lfn', 'local function $1($2)\n  $0\nend'),
    p('mod', 'local M = {}\n\n$0\n\nreturn M'),
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
    p('fn', 'function $1($2)$3 {\n  $0\n}'),
    p('afn', 'const $1 = ($2)$3 => {\n  $0\n}'),
    p('ifn', '($1)$2 => {\n  $0\n}'),
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
    p('fn', 'fn $1($2)$3 {\n  $0\n}'),
    p('res', 'Result<$1, $2>$0'),
    p('opt', 'Option<$1>$0'),
    p('const', 'const $1: $2 = $0;'),
    p('enum', '#[derive(Debug)]\nenum $1 {\n  $0\n}'),
    p('derive', '#[derive($0)]'),
    p('tst', '#[test]'),
    p('impl', 'impl $1 {\n  $0\n}'),
    p('for', 'for $1 in $2 {\n  $0\n}'),
    p('ifl', 'if let Some($1) = $1 {\n  $0\n}'),
  })
end

return M
