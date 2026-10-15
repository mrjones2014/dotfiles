---@type LazySpec
return {
  -- borderless nvchad-style picker
  { import = 'astrocommunity.recipes.picker-nvchad-theme' },
  {
    'folke/snacks.nvim',
    opts = {
      dashboard = { preset = { keys = {} } },
      picker = {
        layout = { preset = 'telescope' },
        sources = {
          grep = {
            hidden = true,
            exclude = { '.git', '.jj', '.direnv' },
          },
          -- only offer recent files under the current project
          recent = {
            filter = {
              paths = {
                [vim.uv.cwd()] = true,
                [string.format('%s/.git/COMMIT_EDITMSG', vim.uv.cwd())] = false,
              },
            },
          },
        },
      },
    },
  },
  {
    -- Picker colour tweaks from my old colorscheme.lua. These have to be applied at
    -- the astroui `highlights` layer, not catppuccin's `custom_highlights`: the nvchad
    -- recipe above also writes these groups through astroui, and astroui highlights
    -- run after the colorscheme. Patching in the same layer, after the recipe, wins.
    'AstroNvim/astroui',
    ---@param opts AstroUIOpts
    opts = function(_, opts)
      if not opts.highlights then
        opts.highlights = {}
      end
      local original = opts.highlights.init
      local init_fn = type(original) == 'table' and function()
        return original
      end or original --[[@as function]]
      opts.highlights.init = require('astrocore').patch_func(init_fn, function(orig, colors_name)
        local hl = orig and orig(colors_name) or {}
        local c = require('catppuccin.palettes').get_palette('mocha')
        local prompt = c.surface0
        hl.SnacksPickerInput = { bg = prompt, fg = c.subtext0 }
        hl.SnacksPickerInputBorder = { bg = prompt, fg = prompt }
        hl.SnacksPickerPrompt = { bg = prompt }
        hl.NormalFloat = { bg = c.base }
        hl.SnacksPickerBoxTitle = { bg = prompt, fg = prompt }
        hl.SnacksPickerBoxBorder = hl.SnacksPickerBoxTitle
        hl.SnacksPickerBorder = { bg = c.base, fg = c.base }
        hl.SnacksPickerPreviewTitle = hl.SnacksPickerBorder
        hl.SnacksPickerResultsTitle = hl.SnacksPickerBorder
        hl.SnacksPickerListTitle = hl.SnacksPickerBorder
        return hl
      end)
    end,
  },
  {
    'AstroNvim/astrocore',
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          ['<Leader>fi'] = {
            function()
              require('snacks').picker.icons({
                icon_sources = { 'nerd_fonts' },
                confirm = { 'copy', 'close' },
              })
            end,
            desc = 'Find nerd font icons',
          },
          ['<Leader>jk'] = {
            function()
              local snacks_ok, snacks = pcall(require, 'snacks')
              if snacks_ok then
                snacks.notifier.hide()
              end
              local noice_ok, noice = pcall(require, 'noice')
              if noice_ok then
                noice.cmd('dismiss')
              end
            end,
            desc = 'Dismiss notifications',
          },
        },
      },
    },
  },
}
