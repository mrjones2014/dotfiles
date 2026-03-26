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

  -- Validate critical config values
  if M.config.input.height <= 0 then
    vim.notify('codecompanion-ui: input.height must be positive, using default', vim.log.levels.WARN)
    M.config.input.height = defaults.input.height
  end

  if M.config.chat.width < 0.0 or M.config.chat.width > 1.0 then
    vim.notify('codecompanion-ui: chat.width must be between 0.0 and 1.0, using default', vim.log.levels.WARN)
    M.config.chat.width = defaults.chat.width
  end

  if M.config.spinner.interval_ms <= 0 then
    vim.notify('codecompanion-ui: spinner.interval_ms must be positive, using default', vim.log.levels.WARN)
    M.config.spinner.interval_ms = defaults.spinner.interval_ms
  end

  if not M.config.spinner.frames or #M.config.spinner.frames == 0 then
    vim.notify('codecompanion-ui: spinner.frames must be non-empty, using default', vim.log.levels.WARN)
    M.config.spinner.frames = defaults.spinner.frames
  end
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
