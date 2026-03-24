local M = {}

---@class CcuiSession
---@field id number
---@field chat_bufnr number
---@field chat_winid number
---@field input_bufnr number
---@field input_winid number
---@field input_split table|nil
---@field chat_at_bottom boolean

---@type table<number, CcuiSession>
M.sessions = {}

---@type number|nil
M.active_session_id = nil

---@param id number
---@param chat_bufnr number
---@param chat_winid number
---@return CcuiSession
function M.create(id, chat_bufnr, chat_winid)
  local session = {
    id = id,
    chat_bufnr = chat_bufnr,
    chat_winid = chat_winid,
    input_bufnr = -1,
    input_winid = -1,
    input_split = nil,
    chat_at_bottom = true,
  }
  M.sessions[id] = session
  M.active_session_id = id
  return session
end

---@param id number
---@return CcuiSession|nil
function M.get(id)
  return M.sessions[id]
end

---@param chat_bufnr number
---@return CcuiSession|nil
function M.get_by_bufnr(chat_bufnr)
  for _, session in pairs(M.sessions) do
    if session.chat_bufnr == chat_bufnr then
      return session
    end
  end
  return nil
end

---@param input_bufnr number
---@return CcuiSession|nil
function M.get_by_input_bufnr(input_bufnr)
  for _, session in pairs(M.sessions) do
    if session.input_bufnr == input_bufnr then
      return session
    end
  end
  return nil
end

---@return CcuiSession|nil
function M.active()
  if M.active_session_id then
    return M.sessions[M.active_session_id]
  end
  return nil
end

---@param id number
function M.remove(id)
  M.sessions[id] = nil
  if M.active_session_id == id then
    M.active_session_id = nil
  end
end

return M
