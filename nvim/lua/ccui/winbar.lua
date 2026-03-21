local State = require('ccui.state')

local M = {}

local modeIcons = {
  default = '',
  acceptEdits = '',
  plan = '󰙬',
  dontAsk = '󱐋',
  bypassPermissions = '󰒃',
}

---Update mode/adapter/model from the chat object into session state
---@param session ccui.Session
function M.refresh_metadata(session)
  local ok, cc = pcall(require, 'codecompanion')
  if not ok then
    return
  end

  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  if chat.adapter then
    session.adapter_name = chat.adapter.formatted_name or chat.adapter.name or ''
  end

  if chat.acp_connection then
    local modes = chat.acp_connection._modes
    if modes then
      local currentId = modes.currentModeId or ''
      local modeInfo = vim.iter(modes.availableModes or {}):find(function(m)
        return m.id == currentId
      end)
      if modeInfo then
        session.mode_name = modeInfo.name
        session.mode_id = modeInfo.id
      end
    end

    local models = chat.acp_connection._models
    if models then
      local currentId = models.currentModelId or ''
      for _, model in ipairs(models.availableModels or {}) do
        if model.modelId == currentId then
          session.model_name = model.name
          break
        end
      end
    end
  end

  if session.mode_name == 'Default' then
    session.mode_name = 'Build Mode'
    session.mode_id = 'default'
  end
  if session.mode_name == '' then
    session.mode_name = 'Plan Mode'
    session.mode_id = 'plan'
  end
end

---Evaluate the winbar string for the chat window
---Called via v:lua from the winbar option
---@return string
function M.eval_chat()
  return ''
end

---Evaluate the winbar string for the input window
---Called via v:lua from the winbar option
---@return string
function M.eval_input()
  local session = State.active()
  if not session then
    return ''
  end

  local parts = {}

  local icon = modeIcons[session.mode_id] or ''
  table.insert(parts, string.format('%%#CcuiModeSep#%%#CcuiMode# %s %s %%#CcuiModeSep#', icon, session.mode_name))

  if session.adapter_name ~= '' then
    table.insert(parts, string.format('%%#CcuiAdapter#  %s %%#CcuiAdapterSep#', session.adapter_name))
  end

  if session.model_name ~= '' then
    table.insert(parts, string.format('%%#CcuiModel# 󰧑 %s ', session.model_name))
  end

  if session.is_processing then
    local frame = State.spinner_frames[session.spinner_idx]
    table.insert(parts, string.format('%%#CcuiSpinner# %s Processing... ', frame))
  end

  return table.concat(parts)
end

---Set the winbar on the input window
---@param winid number window ID
function M.set_input_winbar(winid)
  if vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].winbar = "%{%v:lua.require('ccui.winbar').eval_input()%}"
  end
end

---Redraw the winbar for a session's input window
---@param session ccui.Session
function M.redraw(session)
  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_win_call(session.input_winid, function()
      vim.cmd('redrawstatus')
    end)
  end
end

return M
