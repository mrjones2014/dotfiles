local icons = require('nvim-nonicons')

require('compe').setup({
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    -- vsnip = {kind = '   (Snippet)', priority = 6}, -- enable when I get to adding vsnip
    nvim_lsp = {kind = ' ' .. icons.get('code') .. '  (LSP)', priority = 5},
    nvim_lua = {kind = ' ' .. icons.get('lua') .. '  (nvim Lua)', priority = 4},
    path = {kind = ' ' .. icons.get('ellipsis') .. '  (Path)', priority = 3},
    buffer = {kind = ' ' .. icons.get('file') .. '  (Buffer)', priority = 2},
    spell = {kind = ' ' .. icons.get('pencil') .. '  (Spell)', priority = 1},
 }
})
