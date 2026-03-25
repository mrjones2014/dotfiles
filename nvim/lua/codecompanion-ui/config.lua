local M = {}

---@class CcuiConfig
---@field input CcuiConfig.Input
---@field chat CcuiConfig.Chat
---@field spinner CcuiConfig.Spinner
---@field mode_display_names table<string, string>
---@field mode_icons table<string, string>

---@class CcuiConfig.Input
---@field height number
---@field placeholder string
---@field processing_blocked_message string

---@class CcuiConfig.Chat
---@field width number

---@class CcuiConfig.Spinner
---@field interval_ms number
---@field frames string[]

local defaults = {
  input = {
    height = 10,
    -- Placeholder shown when the input buffer is empty
    placeholder = 'Type your message...',
    -- Message shown in winbar when user tries to submit while processing
    processing_blocked_message = 'Please wait...',
  },
  chat = {
    -- Chat window width as a fraction of the screen (0.0–1.0)
    width = 0.35,
  },
  spinner = {
    interval_ms = 100,
    frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
    text = 'Processing...',
  },
  -- Rename modes for display. Keys are the original mode name, values are the
  -- display name shown in the winbar.
  mode_display_names = {},
  mode_icons = {
    default = '',
    acceptEdits = '󱐋',
    plan = '󰙬',
    dontAsk = '󱐋',
    bypassPermissions = '󰒃',
  },
}

---@type CcuiConfig
M.config = vim.deepcopy(defaults)

---@param opts? CcuiConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
end

---@type CcuiConfig|{setup: fun(opts?: CcuiConfig), config: CcuiConfig}
return setmetatable(M, {
  __index = function(_, key)
    if key == 'setup' then
      return M.setup
    end
    return rawget(M.config, key)
  end,
})
