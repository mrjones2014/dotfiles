local State = require('codecompanion-ui.state')
local Input = require('codecompanion-ui.input')
local Winbar = require('codecompanion-ui.winbar')

local M = {}

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
  vim.wo[winid].winfixwidth = true
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
  local config = require('codecompanion-ui.config')
  vim.wo[winid].signcolumn = 'no'
  vim.wo[winid].number = false
  vim.wo[winid].winfixheight = true
  vim.wo[winid].winfixwidth = true
  vim.api.nvim_win_set_width(winid, math.floor(vim.o.columns * config.chat.width))
end

---@param chat_bufnr number
---@param chat_id number
function M.attach(chat_bufnr, chat_id)
  local config = require('codecompanion-ui.config')

  local existing = State.get(chat_id)
  if existing and existing.input_winid then
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

  -- Create the input split at the bottom of the chat window.
  local input_winid
  vim.api.nvim_win_call(chat_winid, function()
    vim.cmd('belowright ' .. config.input.height .. 'split')
    input_winid = vim.api.nvim_get_current_win()
  end)

  if not input_winid or not vim.api.nvim_win_is_valid(input_winid) then
    return
  end

  vim.api.nvim_win_set_buf(input_winid, input_bufnr)
  vim.b[input_bufnr].codecompanion_chat_bufnr = chat_bufnr

  session.input_winid = input_winid

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

  local group = vim.api.nvim_create_augroup('codecompanion-ui_session_' .. chat_id, { clear = true })
  local programmatic_scroll = false

  vim.api.nvim_buf_attach(chat_bufnr, false, {
    on_lines = function()
      if not session.chat_at_bottom then
        return
      end
      if not vim.api.nvim_win_is_valid(chat_winid) then
        return true -- detach
      end

      vim.schedule(function()
        if not vim.api.nvim_win_is_valid(chat_winid) then
          return
        end
        if not session.chat_at_bottom then
          return
        end

        local line_count = vim.api.nvim_buf_line_count(chat_bufnr)
        if line_count == 0 then
          return
        end

        programmatic_scroll = true
        pcall(vim.api.nvim_win_set_cursor, chat_winid, { line_count, 0 })
        vim.schedule(function()
          programmatic_scroll = false
        end)
      end)
    end,
  })

  vim.api.nvim_create_autocmd('WinScrolled', {
    group = group,
    buffer = chat_bufnr,
    callback = function()
      if programmatic_scroll then
        return
      end
      if not vim.api.nvim_win_is_valid(chat_winid) then
        return
      end

      local last_visible = vim.api.nvim_win_call(chat_winid, function()
        return vim.fn.line('w$')
      end)
      local line_count = vim.api.nvim_buf_line_count(chat_bufnr)
      session.chat_at_bottom = last_visible >= line_count - 1
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

  -- If the input window is closed manually, also close the chat window
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(session.input_winid),
    callback = function()
      pcall(vim.api.nvim_win_close, session.chat_winid, false)
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

  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    pcall(vim.api.nvim_win_close, session.input_winid, true)
  end

  session.input_winid = nil
  session.input_bufnr = nil
end

function M.focus_input()
  local session = State.active()
  if session and session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
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
  return session.input_winid ~= nil and vim.api.nvim_win_is_valid(session.input_winid)
end

return M
