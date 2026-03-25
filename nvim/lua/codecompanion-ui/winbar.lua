local M = {}

---@return string
function M.eval_input()
  local State = require('codecompanion-ui.state')
  local config = require('codecompanion-ui.config')

  local session = State.active()
  if not session then
    return ''
  end

  local ok, cc = pcall(require, 'codecompanion')
  if not ok then
    return ''
  end

  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return ''
  end

  local parts = {}

  -- Mode
  local mode_name = 'Plan Mode'
  local mode_id = 'plan'
  if chat.acp_connection and chat.acp_connection._modes then
    local modes = chat.acp_connection._modes
    local current_id = modes and modes.currentModeId or ''
    local mode_info = vim.iter(modes and modes.availableModes or {}):find(function(m)
      return m.id == current_id
    end)
    if mode_info then
      mode_name = mode_info.name
      mode_id = mode_info.id
    end
  end

  local display_name = config.mode_display_names[mode_name]
  if display_name then
    mode_name = display_name
  end

  local icon = config.mode_icons[mode_id] or ''
  table.insert(parts, string.format('%%#CcuiModeSep#%%#CcuiMode# %s %s %%#CcuiModeSep#', icon, mode_name))

  -- Adapter
  local adapter_name = ''
  if chat.adapter then
    adapter_name = chat.adapter.formatted_name or chat.adapter.name or ''
  end

  if adapter_name ~= '' then
    table.insert(parts, string.format('%%#CcuiAdapter#  %s %%#CcuiAdapterSep#', adapter_name))
  end

  -- Model
  local model_name = nil
  if chat.acp_connection and chat.acp_connection._models then
    local models = chat.acp_connection._models
    local current_id = models and models.currentModelId or ''
    for _, model in ipairs(models and models.availableModels or {}) do
      if model.modelId == current_id then
        model_name = model.name
        break
      end
    end
  end

  if model_name then
    table.insert(parts, string.format('%%#CcuiModel# 󰧑 %s ', model_name))
  end

  if session.is_processing then
    local frames = config.spinner.frames
    local frame = frames[session.spinner_idx] or frames[1]
    table.insert(parts, string.format('%%#CcuiSpinner# %s %s ', frame, config.spinner.text))
  end

  -- Show processing blocked message right-aligned
  if session.processing_blocked then
    table.insert(parts, string.format('%%=%%#WarningMsg# %s ', config.input.processing_blocked_message))
  end

  return table.concat(parts)
end

---@param winid number
function M.set_input_winbar(winid)
  if vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].winbar = "%{%v:lua.require('codecompanion-ui.winbar').eval_input()%}"
  end
end

return M
