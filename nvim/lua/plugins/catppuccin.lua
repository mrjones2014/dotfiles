---@type LazySpec
return {
  { import = 'astrocommunity.colorscheme.catppuccin' },
  {
    'AstroNvim/astroui',
    ---@type AstroUIOpts
    opts = { colorscheme = 'catppuccin-mocha' },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      flavour = 'mocha',
      dim_inactive = { enabled = true },
      custom_highlights = function(c)
        -- cmdline prompt bar
        local prompt = c.surface0
        return {
          -- winbar sits on the section background
          WinBar = { bg = c.surface1 },
          WinBarNC = { bg = c.surface1 },
          NoiceCmdlinePopup = { bg = prompt, fg = c.subtext0 },
          NoiceCmdlinePopupBorder = { bg = prompt, fg = prompt },
          NoiceCmdlinePopupBorderSearch = { bg = prompt, fg = prompt },
        }
      end,
    },
  },
}
