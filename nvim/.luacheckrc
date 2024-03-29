globals = {
  'vim',
  'dbg',
  Path = {
    fields = {
      join = function(...) end,
    },
  },
  Clipboard = {
    fields = {
      copy = function(str) end,
    },
  },
  LSP = {
    fields = {
      on_attach = function(client, bufnr) end,
    },
  },
  TblUtils = {
    fields = {
      join_lists = function(...) end,
    },
  },
  Url = {
    fields = {
      open = function(url) end,
    },
  },
}
