return {
  'b3nj5m1n/kommentary',
  setup = function()
    vim.g.kommentary_create_default_mappings = false
  end,
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>c', '<Plug>kommentary_line_default', {})
    vim.api.nvim_set_keymap('v', '<leader>c', '<Plug>kommentary_visual_default', {})
    local config = require('kommentary.config')
    config.configure_language('default', {
      use_consistent_indentation = true,
      ignore_whitespace = true,
    })
    -- TODO https://github.com/b3nj5m1n/kommentary/issues/65
    --[[ config.configure_language('gohtmltmpl', {
      prefer_multi_line_comments = true,
      single_line_comment_string = false,
      multi_line_comment_string = { '{{/*', '*/}}' },
    }) ]]
  end,
}
