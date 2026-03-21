local State = require('ccui.state')
local Input = require('ccui.input')
local Winbar = require('ccui.winbar')
local Split = require('nui.split')

local M = {}

local INPUT_HEIGHT = 10

---@param bufnr number
---@return number|nil
local function find_win_for_buf(bufnr)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

---@param winid number
local function setup_input_win_opts(winid)
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

---@param winid number
local function setup_chat_win_opts(winid)
  vim.wo[winid].signcolumn = 'no'
  vim.wo[winid].number = false
  vim.wo[winid].winfixheight = false
end

---@param chat_bufnr number
---@param chat_id number
function M.attach(chat_bufnr, chat_id)
  local existing = State.get(chat_id)
  if existing and existing.input_split then
    return
  end

  local chat_winid = find_win_for_buf(chat_bufnr)
  if not chat_winid or not vim.api.nvim_win_is_valid(chat_winid) then
    return
  end

  local session = existing or State.create(chat_id, chat_bufnr, chat_winid)
  session.chat_winid = chat_winid

  local input_bufnr = Input.create_buf()
  session.input_bufnr = input_bufnr

  local input_split = Split({
    relative = {
      type = 'win',
      winid = chat_winid,
    },
    position = 'bottom',
    size = INPUT_HEIGHT,
    buf_options = {
      buftype = 'nofile',
      swapfile = false,
    },
  })

  input_split:mount()

  if not input_split.winid or not vim.api.nvim_win_is_valid(input_split.winid) then
    pcall(function()
      input_split:unmount()
    end)
    return
  end

  vim.api.nvim_win_set_buf(input_split.winid, input_bufnr)
  vim.b[input_bufnr].codecompanion_chat_bufnr = chat_bufnr

  session.input_winid = input_split.winid
  session.input_split = input_split

  setup_chat_win_opts(chat_winid)
  setup_input_win_opts(session.input_winid)

  vim.keymap.set('n', '<Tab>', function()
    M.focus_input()
  end, { buffer = chat_bufnr, silent = true })

  Winbar.set_input_winbar(session.input_winid)

  Input.setup_keymaps(session)
  Input.setup_autocmds(input_bufnr)
  Input.refresh_placeholder(input_bufnr)

  State.active_session_id = chat_id

  local group = vim.api.nvim_create_augroup('ccui_session_' .. chat_id, { clear = true })
  local chat_at_bottom = true

  vim.api.nvim_create_autocmd('WinResized', {
    group = group,
    callback = function()
      if chat_at_bottom and vim.api.nvim_win_is_valid(chat_winid) then
        vim.api.nvim_win_call(chat_winid, function()
          vim.cmd('normal! G')
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd('WinScrolled', {
    group = group,
    buffer = chat_bufnr,
    callback = function()
      if not vim.api.nvim_win_is_valid(chat_winid) then
        return
      end

      local ok, cursor = pcall(vim.api.nvim_win_get_cursor, chat_winid)
      if not ok then
        return
      end

      local line_count = vim.api.nvim_buf_line_count(chat_bufnr)
      chat_at_bottom = cursor[1] >= line_count - 1
    end,
  })

  vim.api.nvim_create_autocmd('BufDelete', {
    group = group,
    buffer = chat_bufnr,
    callback = function()
      M.detach(chat_id)
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })

  vim.api.nvim_set_current_win(session.input_winid)
end

---@param chat_id number
function M.detach(chat_id)
  local session = State.get(chat_id)
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

function M.focus_input()
  local session = State.active()
  if session and session.input_winid > 0 and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_set_current_win(session.input_winid)
  end
end

function M.focus_chat()
  local session = State.active()
  if session and session.chat_winid > 0 and vim.api.nvim_win_is_valid(session.chat_winid) then
    vim.api.nvim_set_current_win(session.chat_winid)
  end
end

---@return boolean
function M.is_visible()
  local session = State.active()
  if not session then
    return false
  end
  return session.input_winid > 0 and vim.api.nvim_win_is_valid(session.input_winid)
end

return M
