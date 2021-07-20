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
    path = { kind = "   (Path)" },
    buffer = { kind = "   (Buffer)" },
    -- vsnip = {kind = "   (Snippet)"}, -- enable when I get to adding vsnip
    nvim_lsp = { kind = "   (LSP)" },
    nvim_lua = { kind = " {} (nvim Lua)" },
    spell = { kind = "   (Spell)" },
  }
})

require('lspkind').init({})
