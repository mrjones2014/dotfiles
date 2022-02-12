local ls = require('luasnip')
local p = ls.parser.parse_snippet

ls.snippets.lua = {
  p('req', "local $1 = require('$2')"),
  p('fn', 'function M.$1($2)\n  $0\nend'),
  p('lfn', 'local function $1($2)\n  $0\nend'),
  p('mod', 'local M = {}\n\n$0\n\nreturn M'),
}

ls.snippets.rust = {
  p('fn', 'fn $1($2)$3 {\n  $0\n}'),
  p('const', 'const $1: $2 = $0;'),
  p('enum', '#[derive(Debug)]\nenum $1 {\n  $0\n}'),
  p('derive', '#[derive($0)]'),
  p('impl', 'impl $1 {\n  $0\n}'),
  p('impl-trait', 'impl $1 for $2 {\n  $0\n}'),
  p('for', 'for $1 in $2 {\n  $0\n}'),
  p('if-let', 'if let Some($1) = $1 {\n  $0\n}'),
}
