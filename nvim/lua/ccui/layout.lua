local State = require('ccui.state')
local Input = require('ccui.input')
local Winbar = require('ccui.winbar')
local Split = require('nui.split')

local api = vim.api

local M = {}

local INPUT_HEIGHT = 10

---Find the window displaying a given buffer
---@param bufnr number buffer number
---@return number|nil window ID if found
local function findWinForBuf(bufnr)
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

---Configure window options for the input window
---@param winid number window ID
local function setupInputWinOpts(winid)
  vim.wo[winid].winfixheight = true
  vim.wo[winid].winfixwidth = false
  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].signcolumn = 'no'
  vim.wo[winid].cursorline = false
  vim.wo[winid].wrap = true
  vim.wo[winid].linebreak = true
  vim.wo[winid].breakindent = true
end

---Configure window options for the chat window
---@param winid number window ID
local function setupChatWinOpts(winid)
  vim.wo[winid].signcolumn = 'no'
  vim.wo[winid].number = false
  vim.wo[winid].winfixheight = false
end

---Attach our UI to a CodeCompanion chat buffer
---Creates an input window below the chat window
---@param chatBufnr number chat buffer number
---@param chatId number chat ID
function M.attach(chatBufnr, chatId)
  local existing = State.get(chatId)
  if existing and existing.input_split then
    return
  end

  local chatWinid = findWinForBuf(chatBufnr)
  if not chatWinid or not api.nvim_win_is_valid(chatWinid) then
    return
  end

  local session = existing or State.create(chatId, chatBufnr, chatWinid)
  session.chat_winid = chatWinid

  local inputBufnr = Input.create_buf()
  session.input_bufnr = inputBufnr

  local inputSplit = Split({
    relative = {
      type = 'win',
      winid = chatWinid,
    },
    position = 'bottom',
    size = INPUT_HEIGHT,
    buf_options = {
      buftype = 'nofile',
      swapfile = false,
    },
  })

  inputSplit:mount()

  if not inputSplit.winid or not api.nvim_win_is_valid(inputSplit.winid) then
    pcall(function()
      inputSplit:unmount()
    end)
    return
  end

  vim.api.nvim_win_set_buf(inputSplit.winid, inputBufnr)

  session.input_winid = inputSplit.winid
  session.input_split = inputSplit

  setupChatWinOpts(chatWinid)
  setupInputWinOpts(session.input_winid)

  vim.keymap.set('n', '<Tab>', function()
    M.focus_input()
  end, { buffer = chatBufnr, silent = true })

  Winbar.refresh_metadata(session)
  Winbar.set_input_winbar(session.input_winid)

  Input.setup_keymaps(session)
  Input.setup_autocmds(inputBufnr)
  Input.refresh_placeholder(inputBufnr)

  State.active_session_id = chatId

  local group = api.nvim_create_augroup('ccui_session_' .. chatId, { clear = true })
  local chatAtBottom = true

  api.nvim_create_autocmd('WinResized', {
    group = group,
    callback = function()
      if chatAtBottom and api.nvim_win_is_valid(chatWinid) then
        vim.api.nvim_win_call(chatWinid, function()
          vim.cmd('normal! G')
        end)
      end
    end,
  })

  api.nvim_create_autocmd('WinScrolled', {
    group = group,
    buffer = chatBufnr,
    callback = function()
      if not api.nvim_win_is_valid(chatWinid) then
        return
      end

      local ok, cursor = pcall(api.nvim_win_get_cursor, chatWinid)
      if not ok then
        return
      end

      local lineCount = api.nvim_buf_line_count(chatBufnr)
      chatAtBottom = cursor[1] >= lineCount - 1
    end,
  })

  api.nvim_create_autocmd('BufDelete', {
    group = group,
    buffer = chatBufnr,
    callback = function()
      M.detach(chatId)
      pcall(api.nvim_del_augroup_by_id, group)
    end,
  })

  api.nvim_create_autocmd('BufDelete', {
    group = group,
    buffer = inputBufnr,
    callback = function()
      if api.nvim_buf_is_valid(chatBufnr) then
        pcall(api.nvim_buf_delete, chatBufnr, { force = false })
      end
    end,
  })

  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(chatWinid),
    callback = function()
      M.detach(chatId)
    end,
  })

  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(session.input_winid),
    callback = function()
      if api.nvim_win_is_valid(chatWinid) then
        pcall(api.nvim_win_close, chatWinid, false)
      end
    end,
  })

  api.nvim_set_current_win(session.input_winid)
end

---Detach our UI from a CodeCompanion chat
---Unmounts the input split and cleans up session state
---@param chatId number chat ID
function M.detach(chatId)
  local session = State.get(chatId)
  if not session then
    return
  end

  if session.input_split then
    pcall(function()
      session.input_split:unmount()
    end)
    session.input_split = nil
  end

  session.input_winid = -1
  session.input_bufnr = -1
end

---Focus the input window of the active session
function M.focus_input()
  local session = State.active()
  if session and session.input_winid > 0 and api.nvim_win_is_valid(session.input_winid) then
    api.nvim_set_current_win(session.input_winid)
  end
end

---Focus the chat window of the active session
function M.focus_chat()
  local session = State.active()
  if session and session.chat_winid > 0 and api.nvim_win_is_valid(session.chat_winid) then
    api.nvim_set_current_win(session.chat_winid)
  end
end

---Check if the ccui is currently visible
---@return boolean
function M.is_visible()
  local session = State.active()
  if not session then
    return false
  end
  return session.input_winid > 0 and api.nvim_win_is_valid(session.input_winid)
end

return M
