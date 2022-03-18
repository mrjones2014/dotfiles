local ls = require('luasnip')
local s = ls.s
local i = ls.insert_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt
local p = ls.parser.parse_snippet

ls.snippets.lua = {
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
}

ls.snippets.rust = {
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
}
