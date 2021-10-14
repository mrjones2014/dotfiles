return {
  'b3nj5m1n/kommentary',
  setup = function()
    vim.g.kommentary_create_default_mappings = false
  end,
  config = function()
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
