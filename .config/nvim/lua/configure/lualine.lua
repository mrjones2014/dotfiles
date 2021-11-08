return {
  'nvim-lualine/lualine.nvim',
  after = 'lighthaus.nvim',
  config = function()
    local lualine_theme = 'lighthaus_dark'

    local function is_file_open()
      return #(vim.fn.expand('%')) > 0
    end

    local function filepath()
      local path = vim.fn.expand('%')
      if vim.fn.winwidth(0) <= 84 then
        path = vim.fn.pathshorten(path)
      end

      if not path or #path == 0 then
        return ''
      end

      local icon = require('nvim-web-devicons').get_icon(path)
      return icon .. '  ' .. path
    end

    require('lualine').setup({
      options = {
        theme = lualine_theme,
        disabled_filetypes = { 'NvimTree', 'term', 'terminal', 'TelescopePrompt' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = {
          filepath,
          {
            'diagnostics',
            sources = { 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            always_visible = is_file_open,
            update_in_insert = true,
          },
        },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {},
      extensions = { 'nvim-tree' },
    })
  end,
}
