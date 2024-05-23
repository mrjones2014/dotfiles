local function get_tokyonight_hl_fg(hl, group, guard)
  -- don't allow more than 5 levels of recursion
  guard = guard or 0
  if guard > 5 then
    return nil
  end

  if not hl[group] then
    return nil
  end

  if hl[group].link then
    return get_tokyonight_hl_fg(hl, hl[group].link, guard + 1)
  end

  return hl[group].fg
end

return {
  {
    'catppuccin/nvim',
    enabled = vim.env.COLORSCHEME == 'catppuccin',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    opts = {
      flavour = 'mocha',
      dim_inactive = { enabled = true, percentage = 0.000001 },
      styles = {
        loops = { 'italic' },
        keyword = { 'italic' },
      },
      custom_highlights = function(colors)
        return {
          WinBar = { bg = colors.surface2 },
          TelescopeNormal = { bg = colors.crust },
          TelescopeBorder = { bg = colors.crust, fg = colors.crust },
          TelescopePromptBorder = { bg = colors.base, fg = colors.base },
          TelescopePromptNormal = { bg = colors.base },
          TelescopePromptPrefix = { bg = colors.base },
        }
      end,
      integrations = {
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_saga = true,
        markdown = true,
        mini = { enabled = true },
        neotest = true,
        notify = true,
        cmp = true,
        native_lsp = { enabled = true },
        navic = {
          enabled = true,
          -- TODO if I use 'surface2' here I get an error
          custom_bg = '#585b70', ---@diagnostic disable-line: assign-type-mismatch
        },
        semantic_tokens = true,
        treesitter = true,
        rainbow_delimiters = true,
        octo = true,
        telescope = { enabled = true, style = 'nvchad' },
        lsp_trouble = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },
  {
    'folke/tokyonight.nvim',
    enabled = vim.env.COLORSCHEME == 'tokyonight',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
      dim_inactive = true,
      on_highlights = function(hl, c)
        hl.WinBar = { bg = c.fg_gutter }
        hl.WinBarNC = hl.WinBar
        -- navic in winbar
        hl.NavicText.bg = c.fg_gutter
        hl.NavicSeparator.bg = c.fg_gutter
        for key, _ in pairs(hl) do
          if vim.startswith(key, 'NavicIcons') then
            hl[key] = { bg = hl.WinBar.bg, fg = get_tokyonight_hl_fg(hl, key) }
          end
        end
        -- borderless telescope
        local prompt = '#2d3149'
        hl.TelescopeNormal = {
          bg = c.bg,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg,
          fg = c.bg,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = c.bg_dark,
          fg = c.fg,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg,
          fg = c.bg,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg,
          fg = c.bg,
        }
      end,
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },
}
