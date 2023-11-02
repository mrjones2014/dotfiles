return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  config = function()
    require('dressing').setup({
      select = {
        get_config = function(opts)
          opts = opts or {}
          local cfg = {
            telescope = {
              layout_config = {
                width = 120,
                height = 25,
              },
            },
          }
          if opts.kind == 'legendary.nvim' then
            cfg.telescope.sorter = require('telescope.sorters').fuzzy_with_index_bias({})
          elseif opts.prompt == 'Select process: ' then
            -- nvim-dap process picker needs extra width to see full process names
            cfg.telescope.layout_config = {
              width = vim.o.columns - 4,
              height = 50,
            }
          end
          return cfg
        end,
      },
    })
  end,
}
