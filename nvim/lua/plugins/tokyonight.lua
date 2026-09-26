---@type LazySpec
return {
  { import = 'astrocommunity.colorscheme.tokyonight-nvim' },
  {
    'AstroNvim/astroui',
    ---@type AstroUIOpts
    opts = { colorscheme = 'tokyonight-night' },
  },
  {
    'folke/tokyonight.nvim',
    opts = {
      style = 'night',
      dim_inactive = true,
      plugins = { auto = true },
      on_highlights = function(hl, c)
        -- winbar sits on the section background
        hl.WinBar = { bg = c.fg_gutter }
        hl.WinBarNC = hl.WinBar

        -- cmdline prompt bar
        local prompt = '#2d3149'
        hl.NoiceCmdlinePopup = { bg = prompt, fg = c.fg_dark }
        hl.NoiceCmdlinePopupBorder = { bg = prompt, fg = prompt }
      end,
    },
  },
}
