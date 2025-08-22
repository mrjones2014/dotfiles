local Snippets = {}

local LUA_MODULE_RETURN_TS_QUERY = [[
(return_statement
	(expression_list
		(identifier) @return-value-name))
]]

function Snippets.lua()
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
    if parser == nil then
      error('Install Lua treesitter parser')
    end
    local tree = parser:parse()[1]
    local num_lines = #vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local _, node = query:iter_captures(tree:root(), 0, num_lines - 3, num_lines)()
    return vim.treesitter.get_node_text(node, 0, {})
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
    p('mod', 'local $1 = {}\n\n$0\n\nreturn $1'),
    -- require without assigning to a local
    p('rq', "require('$0')"),
    -- inline global function
    p('fn', 'function($1)\n  $0\nend'),
    -- inline local function
    p('lfn', 'local function $1($2)\n  $0\nend'),
  })
end

function Snippets.rust()
  local ls = require('luasnip')
  local p = ls.parser.parse_snippet
  ls.add_snippets('rust', {
    p('deny', '#![deny(clippy::all, clippy::pedantic, rust_2018_idioms, clippy::unwrap_used)]\n\n', {}),
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
    p('lets', 'let Some($1) = $1 else {\n  $0\n};'),
    p('leto', 'let Ok($1) = $1 else {\n  $0\n};'),
  })
end

function Snippets.nix()
  local ls = require('luasnip')
  local p = ls.parser.parse_snippet
  ls.add_snippets('nix', {
    p(
      'flake',
      [[{
  description = "$1";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";$2
  };
  outputs = inputs@{ nixpkgs, ... }: {
    $0
  };
}]]
    ),
  })
end

return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  keys = {
    {
      '<C-h>',
      function()
        require('luasnip').jump(-1)
      end,
      mode = { 'i', 's' },
      desc = 'Jump to previous snippet node',
    },
    {
      '<C-l>',
      function()
        local ls = require('luasnip')
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end,
      mode = { 'i', 's' },
      desc = 'Expand or jump to next snippet node',
    },
    {
      '<C-j>',
      function()
        local ls = require('luasnip')
        if ls.choice_active() then
          ls.change_choice(-1)
        end
      end,
      mode = { 'i', 's' },
      desc = 'Select previous choice in snippet choice nodes',
    },
    {
      '<C-k>',
      function()
        local ls = require('luasnip')
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end,
      mode = { 'i', 's' },
      desc = 'Select next choice in snippet choice nodes',
    },
    {
      '<C-s>',
      function()
        require('luasnip').unlink_current()
      end,
      mode = { 'i', 'n' },
      desc = 'Clear snippet jumps',
    },
  },
  config = function()
    for _, snippets in pairs(Snippets) do
      snippets()
    end
  end,
}
