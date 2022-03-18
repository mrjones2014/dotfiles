_G._printed = 0
return {
  'stevearc/dressing.nvim',
  config = function()
    require('dressing').setup(
      -- {
      --   select = {
      --     get_config = function(opts)
      --       if vim.startswith(opts.kind or '', 'legendary') then
      --         local sorter = require('telescope.config').values.generic_sorter(opts)
      --         local score_fn = vim.deepcopy(sorter.scoring_function)
      --         sorter.scoring_function = function(a, b, c)
      --           if _G._printed < 3 then
      --             print(vim.inspect(a))
      --             print(vim.inspect(b))
      --             print(vim.inspect(c))
      --             _G._printed = _G._printed + 1
      --           end
      --           return score_fn(a, b, c)
      --         end
      --         return {
      --           telescope = {
      --             sorter = sorter,
      --           },
      --         }
      --       end
      --     end,
      --   },
      -- }
    )
  end,
}
