local api = vim.api
local NS_PLACEHOLDER = api.nvim_create_namespace('ccui_placeholder')

local M = {}

---Create a new input buffer
---@return number buffer number
function M.create_buf()
  vim.treesitter.language.register('markdown', 'codecompanion_input')

  local buf = api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'codecompanion_input'
  return buf
end

---Submit the input buffer contents to CodeCompanion
---@param session ccui.Session
function M.submit(session)
  if not session or not api.nvim_buf_is_valid(session.input_bufnr) then
    return
  end

  local lines = api.nvim_buf_get_lines(session.input_bufnr, 0, -1, false)
  local text = vim.trim(table.concat(lines, '\n'))
  if text == '' then
    return
  end

  api.nvim_buf_set_lines(session.input_bufnr, 0, -1, false, { '' })
  M.refresh_placeholder(session.input_bufnr)

  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  chat.ui:unlock_buf()
  local lineCount = api.nvim_buf_line_count(chat.bufnr)
  local textLines = vim.split(text, '\n', { plain = true })
  api.nvim_buf_set_lines(chat.bufnr, lineCount, lineCount, false, textLines)

  chat:submit()
end

---Set up keymaps on the input buffer
---@param session ccui.Session
function M.setup_keymaps(session)
  local buf = session.input_bufnr
  local opts = { buffer = buf, silent = true }

  vim.keymap.set('n', '<CR>', function()
    M.submit(session)
  end, opts)

  vim.keymap.set({ 'n', 'i' }, '<C-s>', function()
    M.submit(session)
  end, opts)

  vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
    local cc = require('codecompanion')
    local chat = cc.buf_get_chat(session.chat_bufnr)
    if chat then
      chat:stop()
    end
  end, opts)

  vim.keymap.set('n', 'q', function()
    local cc = require('codecompanion')
    local chat = cc.buf_get_chat(session.chat_bufnr)
    if chat then
      chat:stop()
    end
  end, opts)

  vim.keymap.set('n', 'gh', function()
    local cc = require('codecompanion')
    local chat = cc.buf_get_chat(session.chat_bufnr)
    if not chat then
      return
    end

    local chatWinid = session.chat_winid
    if chatWinid and vim.api.nvim_win_is_valid(chatWinid) then
      vim.wo[chatWinid].winfixbuf = false
    end

    local config = require('codecompanion.config')
    local keymaps = config.interactions.chat.keymaps
    if keymaps and keymaps['Saved Chats'] and keymaps['Saved Chats'].callback then
      keymaps['Saved Chats'].callback(chat)
    end

    vim.schedule(function()
      if chatWinid and vim.api.nvim_win_is_valid(chatWinid) then
        vim.wo[chatWinid].winfixbuf = true
      end
    end)
  end, opts)
end

---Set up autocmds for placeholder management
---@param bufnr number buffer number
function M.setup_autocmds(bufnr)
  local group = api.nvim_create_augroup('ccui_input_' .. bufnr, { clear = true })

  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      M.refresh_placeholder(bufnr)
    end,
  })

  api.nvim_create_autocmd('InsertEnter', {
    group = group,
    buffer = bufnr,
    callback = function()
      M.refresh_placeholder(bufnr)
    end,
  })
end

---Show or hide the placeholder based on buffer content
---@param bufnr number buffer number
function M.refresh_placeholder(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  api.nvim_buf_clear_namespace(bufnr, NS_PLACEHOLDER, 0, -1)

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 1 and lines[1] == '' then
    api.nvim_buf_set_extmark(bufnr, NS_PLACEHOLDER, 0, 0, {
      virt_text = {
        { 'Type your message...', 'CcuiPlaceholder' },
      },
      virt_text_pos = 'overlay',
    })
  end
end

return M
