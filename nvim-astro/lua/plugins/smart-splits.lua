---@type LazySpec
return {
  -- NOTE: do *not* disable AstroNvim's `mrjones2014/smart-splits.nvim` spec — it carries
  -- the <C-hjkl> move and <C-arrow> resize mappings via its astrocore `specs`. Disabling
  -- it silently dropped them. Same plugin name here, so lazy merges rather than
  -- duplicates, and `dev = true` resolves it to ~/git/smart-splits.nvim (the new org).
  {
    'mrjones2014/smart-splits.nvim',
    dependencies = { 'smart-splits-nvim/backend-ghostty', main = 'smart-splits-backend-ghostty' },
    dev = true,
    lazy = false,
    branch = 'v3',
    opts = {
      mux = { backend = 'smart-splits-backend-ghostty' },
      move = { at_edge = 'split' },
      ignored_buftypes = { 'nofile' },
      swap = { move_cursor = true },
      diagnostic = { enabled = true },
    },
    specs = {
      {
        'AstroNvim/astrocore',
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              -- alt-hjkl resize, alongside AstroNvim's <C-arrow> bindings
              ['<A-h>'] = {
                function()
                  require('smart-splits').resize_left()
                end,
                desc = 'Resize split left',
              },
              ['<A-j>'] = {
                function()
                  require('smart-splits').resize_down()
                end,
                desc = 'Resize split down',
              },
              ['<A-k>'] = {
                function()
                  require('smart-splits').resize_up()
                end,
                desc = 'Resize split up',
              },
              ['<A-l>'] = {
                function()
                  require('smart-splits').resize_right()
                end,
                desc = 'Resize split right',
              },
              ['<Leader><Leader>h'] = {
                function()
                  require('smart-splits').swap_buf_left()
                end,
                desc = 'Swap buffer left',
              },
              ['<Leader><Leader>j'] = {
                function()
                  require('smart-splits').swap_buf_down()
                end,
                desc = 'Swap buffer down',
              },
              ['<Leader><Leader>k'] = {
                function()
                  require('smart-splits').swap_buf_up()
                end,
                desc = 'Swap buffer up',
              },
              ['<Leader><Leader>l'] = {
                function()
                  require('smart-splits').swap_buf_right()
                end,
                desc = 'Swap buffer right',
              },
            },
          },
        },
      },
    },
  },
}
