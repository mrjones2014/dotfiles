local dirs = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
}

local function mappings()
  local keymaps = {}
  for key, dir in pairs(dirs) do
    keymaps[('<A-%s>'):format(key)] = {
      function()
        require('smart-splits')[('resize_%s'):format(dir)]()
      end,
      desc = ('Resize split %s'):format(dir),
    }
    keymaps[('<leader><leader>%s'):format(key)] = {
      function()
        require('smart-splits')[('swap_buf_%s'):format(dir)]()
      end,
      desc = ('Resize split %s'):format(dir),
    }
  end
  return keymaps
end

---@type LazySpec
return {
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
          -- the rest of the mappings are predefined in the AstroNvim defaults
          mappings = {
            n = mappings(),
          },
        },
      },
    },
  },
}
