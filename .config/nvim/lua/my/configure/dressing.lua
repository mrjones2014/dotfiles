return {
  'stevearc/dressing.nvim',
  event = 'VimEnter',
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
            cfg.telescope.sorter = require('legendary.integrations.telescope').get_sorter({
              most_recent_first = true,
              user_items_first = true,
            })
          end
          return cfg
        end,
      },
    })
  end,
}
