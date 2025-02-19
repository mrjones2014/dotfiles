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

local colorscheme = vim.env.COLORSCHEME or 'tokyonight'

return {
  'folke/tokyonight.nvim',
  dependencies = {
    {
      'folke/snacks.nvim',
      opts = {
        indent = {
          animate = { enabled = false },
        },
      },
    },
  },
  enabled = colorscheme == 'tokyonight',
  lazy = false,
  priority = 1000,
  opts = {
    style = 'night',
    dim_inactive = true,
    plugins = { auto = true },
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
      -- borderless pickers
      local prompt = '#2d3149'
      hl.SnacksPickerInput = {
        bg = prompt,
        fg = c.fg_dark,
      }
      hl.SnacksPickerInputBorder = {
        bg = prompt,
        fg = prompt,
      }
      hl.SnacksPickerPrompt = {
        bg = prompt,
      }
      hl.NormalFloat = {
        bg = c.bg,
      }
      hl.SnacksPickerBoxTitle = {
        bg = prompt,
        fg = prompt,
      }
      hl.SnacksPickerBoxBorder = hl.SnacksPickerBoxTitle
      hl.SnacksPickerBorder = {
        bg = c.bg,
        fg = c.bg,
      }
      hl.SnacksPickerPreviewTitle = hl.SnacksPickerBorder
      hl.SnacksPickerResultsTitle = hl.SnacksPickerBorder
      hl.SnacksPickerListTitle = hl.SnacksPickerBorder
    end,
  },
  config = function(_, opts)
    require('tokyonight').setup(opts)
    vim.cmd.colorscheme('tokyonight-night')
  end,
}
