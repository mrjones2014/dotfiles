local update_cmd = ':TSUpdate'
-- Run TSUpdateSync if running headless
if #vim.api.nvim_list_uis() == 0 then
  update_cmd = ':TSUpdateSync'
end

return {
  'nvim-treesitter/nvim-treesitter',
  requires = {
    'p00f/nvim-ts-rainbow',
    'windwp/nvim-ts-autotag',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'andymass/vim-matchup',
  },
  run = update_cmd,
  setup = function()
    vim.g.matchup_matchparen_offscreen = {
      method = 'popup',
    }
  end,
  config = function()
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
      },
      incremental_selection = {
        enable = true,
        -- keymaps defined in keymaps/init.lua
        keymaps = {},
      },
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 1500,
      },
      autotag = {
        enable = true,
      },
      context_commentstring = {
        enable = true,
      },
      matchup = {
        enable = true,
        include_match_words = true,
      },
    })
  end,
}
