-- Highlight overrides carried over from my old colorscheme.lua.
--
-- NOTE: deliberately NOT reusing the SnacksPicker* groups for the noice cmdline.
-- The `recipes.picker-nvchad-theme` import owns those via astroui highlights, which
-- are applied after the colorscheme, so anything set here would just lose.
---@type LazySpec
return {
  { import = 'astrocommunity.colorscheme.tokyonight-nvim' },
  {
    -- the pack only registers the plugin lazily; AstroNvim still has to be told to use it
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
