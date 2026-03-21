local M = {}

---@class ccui.Session
---@field id number chat ID
---@field chat_bufnr number CodeCompanion chat buffer
---@field chat_winid number CodeCompanion chat window
---@field input_bufnr number input buffer
---@field input_winid number input window
---@field input_split table|nil nui Split object for input window
---@field adapter_name string current adapter display name
---@field model_name string current model display name
---@field mode_name string current mode (Plan Mode, Build Mode, etc.)
---@field mode_id string current mode ID (plan, default, etc.)
---@field is_processing boolean whether LLM is currently responding
---@field spinner_idx number current spinner animation frame
---@field timer uv.uv_timer_t|nil timer for spinner animation

---@type table<number, ccui.Session>
M.sessions = {}

---@type number|nil
M.active_session_id = nil

M.spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

---Create a new session for a CodeCompanion chat
---@param id number chat ID
---@param chat_bufnr number chat buffer number
---@param chat_winid number chat window ID
---@return ccui.Session
function M.create(id, chat_bufnr, chat_winid)
  local session = {
    id = id,
    chat_bufnr = chat_bufnr,
    chat_winid = chat_winid,
    input_bufnr = -1,
    input_winid = -1,
    input_split = nil,
    adapter_name = '',
    model_name = '',
    mode_name = 'Plan Mode',
    mode_id = 'plan',
    is_processing = false,
    spinner_idx = 1,
    timer = nil,
  }
  M.sessions[id] = session
  M.active_session_id = id
  return session
end

---Get session by chat ID
---@param id number
---@return ccui.Session|nil
function M.get(id)
  return M.sessions[id]
end

---Get session by chat buffer number
---@param chat_bufnr number
---@return ccui.Session|nil
function M.get_by_bufnr(chat_bufnr)
  for _, session in pairs(M.sessions) do
    if session.chat_bufnr == chat_bufnr then
      return session
    end
  end
  return nil
end

---Get the currently active session
---@return ccui.Session|nil
function M.active()
  if M.active_session_id then
    return M.sessions[M.active_session_id]
  end
  return nil
end

---Remove a session and clean up its timer
---@param id number
function M.remove(id)
  local session = M.sessions[id]
  if not session then
    return
  end
  if session.timer then
    session.timer:stop()
    session.timer:close()
    session.timer = nil
  end
  M.sessions[id] = nil
  if M.active_session_id == id then
    M.active_session_id = nil
  end
end

return M
