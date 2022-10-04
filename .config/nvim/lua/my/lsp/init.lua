-- always load null-ls
require('my.lsp.null-ls')

-- lazy-load the rest of the configs with
-- an autocommand that runs only once
-- for each lsp config
local legendary = require('legendary')
for filetype, file_patterns in pairs(require('my.lsp.filetypes').filetype_patterns) do
  legendary.bind_autocmds({
    'BufReadPre',
    function()
      require('my.lsp.' .. filetype)
      local snippets = require('my.lsp.snippets')[filetype]
      if snippets then
        snippets()
      end
    end,
    opts = {
      pattern = file_patterns,
      once = true,
    },
  })
end
