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
    ---@module 'catppuccin'
    ---@type CatppuccinOptions
    opts = {
      flavour = 'mocha',
      dim_inactive = { enabled = true },
      custom_highlights = function(c)
        -- cmdline prompt bar
        local prompt = c.surface0
        local h1_color = c.blue
        return {
          -- winbar sits on the section background
          WinBar = { bg = c.surface1 },
          WinBarNC = { bg = c.surface1 },
          NoiceCmdlinePopup = { bg = prompt, fg = c.subtext0 },
          NoiceCmdlinePopupBorder = { bg = prompt, fg = prompt },
          NoiceCmdlinePopupBorderSearch = { bg = prompt, fg = prompt },

          -- markdown: drop catppuccin's red for bold/italic/H1
          ['@markup.strong'] = { fg = c.text },
          ['@markup.italic'] = { fg = c.text },
          rainbow1 = { fg = h1_color }, -- @markup.heading.1.markdown + markdownH1 link here
          -- render-markdown computes these from *default* rainbow1, so set directly
          RenderMarkdownH1 = { fg = h1_color },
          RenderMarkdownH1Bg = { bg = require('catppuccin.utils.colors').darken(h1_color, 0.095, c.base) },
        }
      end,
    },
  },
}
