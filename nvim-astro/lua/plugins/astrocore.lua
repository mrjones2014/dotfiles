---@type LazySpec
return {
  'AstroNvim/astrocore',
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        showtabline = 0,
        relativenumber = false,
      },
    },
    mappings = {
      n = {
        -- AstroNvim only maps <Tab>/<S-Tab> in visual mode (indent), so normal mode
        -- is free for buffer cycling like my old config
        ['<Tab>'] = { vim.cmd.bnext, desc = 'Move to next buffer' },
        ['<S-Tab>'] = { vim.cmd.bprevious, desc = 'Move to previous buffer' },
        -- AstroNvim maps these to `:split` / `:vsplit`; I don't want them
        ['\\'] = false,
        ['|'] = false,
      },
    },
  },
}
