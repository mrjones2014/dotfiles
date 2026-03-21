--- CCUI: Custom CodeCompanion Chat UI
--- TODO:
--- - It sometimes doesn't play nicely with `require('codecompanion').toggle()`, usually if it's the last window
--- - Sometimes pressing enter on like a completion or something causes the output window to close
--- - The output buffer default virtual text doesn't go away because I don't go into insert mode in the output buffer

local M = {}

---Define highlight groups using tokyonight colors
local function setupHighlights()
  local ok, colors = pcall(function()
    return require('tokyonight.colors').setup()
  end)
  if not ok then
    return
  end

  local bgGutter = colors.fg_gutter
  local bgSurface1 = colors.dark3
  local bgSurface2 = colors.blue7

  vim.api.nvim_set_hl(0, 'CcuiModeSep', { fg = bgSurface2, bg = bgGutter })
  vim.api.nvim_set_hl(0, 'CcuiMode', { fg = colors.blue, bg = bgSurface2, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiAdapter', { fg = colors.cyan, bg = bgSurface1 })
  vim.api.nvim_set_hl(0, 'CcuiAdapterSep', { fg = bgSurface1, bg = bgGutter })

  vim.api.nvim_set_hl(0, 'CcuiModel', { fg = colors.green, bg = bgGutter })

  vim.api.nvim_set_hl(0, 'CcuiSpinner', { fg = colors.dark5, bg = bgGutter, bold = true })

  vim.api.nvim_set_hl(0, 'CcuiPlaceholder', { fg = colors.dark5, italic = true })
  vim.api.nvim_set_hl(0, 'CcuiPlaceholderKey', { fg = colors.blue, bold = true })
end

---Setup ccui
---@param opts? table configuration options
function M.setup(opts)
  opts = opts or {}

  setupHighlights()

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('ccui_colors', { clear = true }),
    callback = setupHighlights,
  })

  require('ccui.events').setup()
end

---Focus the input window (public API for keymaps)
function M.focus_input()
  require('ccui.layout').focus_input()
end

---Check if ccui is visible
---@return boolean
function M.is_visible()
  return require('ccui.layout').is_visible()
end

return M
