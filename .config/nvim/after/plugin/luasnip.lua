local ls = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep
local s = ls.s
local i = ls.insert_node
local p = ls.parser.parse_snippet

ls.snippets.lua = {
  s('req', fmt("local {} = require('{}')", { i(1, 'default'), rep(1) })),
  p('fn', 'function M.$1()\n  $0\nend'),
  p('lfn', 'local function $1()\n  $0\nend'),
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
