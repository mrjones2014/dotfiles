local function get_hl_fg(hl, group, guard)
  -- don't allow more than 5 levels of recursion
  guard = guard or 0
  if guard > 5 then
    return nil
  end

  if not hl[group] then
    return nil
  end

  if hl[group].link then
    return get_hl_fg(hl, hl[group].link, guard + 1)
  end

  return hl[group].fg
end

return {
  'folke/tokyonight.nvim',
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
          hl[key] = { bg = hl.WinBar.bg, fg = get_hl_fg(hl, key) }
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
        bg = prompt,
        fg = prompt,
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
}
