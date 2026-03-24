local M = {}

local NS_PLACEHOLDER = vim.api.nvim_create_namespace('codecompanion-nui_placeholder')

---@return number
function M.create_buf()
  vim.treesitter.language.register('markdown', 'codecompanion_input')

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'codecompanion_input'
  return buf
end

---@param session CcuiSession
function M.submit(session)
  if not session or not vim.api.nvim_buf_is_valid(session.input_bufnr) then
    return
  end

  local events = require('codecompanion-nui.events')
  if events.is_processing() then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(session.input_bufnr, 0, -1, false)
  local text = vim.trim(table.concat(lines, '\n'))
  if text == '' then
    return
  end

  vim.api.nvim_buf_set_lines(session.input_bufnr, 0, -1, false, { '' })
  M.refresh_placeholder(session.input_bufnr)

  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  chat.ui:unlock_buf()
  local line_count = vim.api.nvim_buf_line_count(chat.bufnr)
  local text_lines = vim.split(text, '\n', { plain = true })
  vim.api.nvim_buf_set_lines(chat.bufnr, line_count, line_count, false, text_lines)

  local chat_lines = vim.api.nvim_buf_get_lines(chat.bufnr, 0, -1, false)
  for i, line in ipairs(chat_lines) do
    if line:match('^%s*$') or line:match('Enter prompt') then
      vim.api.nvim_buf_clear_namespace(chat.bufnr, -1, i - 1, i)
    end
  end

  -- on submit, scroll the chat buffer to bottom and re-engage autoscroll
  session.chat_at_bottom = true
  if vim.api.nvim_win_is_valid(session.chat_winid) then
    local chat_line_count = vim.api.nvim_buf_line_count(session.chat_bufnr)
    pcall(vim.api.nvim_win_set_cursor, session.chat_winid, { chat_line_count, 0 })
  end

  chat:submit()
end

---@param session CcuiSession
function M.setup_keymaps(session)
  local input_buf = session.input_bufnr

  -- Apply codecompanion's chat keymaps to the input buffer
  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  -- we override send and codeblock keymaps
  local config = require('codecompanion.config')
  local cc_keymaps = vim.deepcopy(config.interactions.chat.keymaps)
  local filtered_keymaps = {}
  for name, keymap in pairs(cc_keymaps) do
    -- skip 'send', 'codeblock', and 'special' keymaps
    if name ~= 'send' and name ~= 'codeblock' and not vim.startswith(name, '_') then
      filtered_keymaps[name] = keymap
    end
  end
  local callbacks = {}
  for name, callback in pairs(require('codecompanion.interactions.chat.keymaps')) do
    if name ~= 'send' then
      callbacks[name] = function(...)
        if type(callback.callback) ~= 'function' then
          vim.notify(string.format('Callback for keymap %s is not a function', name), vim.log.levels.ERROR)
        end
        local cur_win = vim.api.nvim_get_current_win()
        local new_win
        local args = { ... }
        vim.api.nvim_buf_call(session.chat_bufnr, function()
          callback.callback(unpack(args))
          new_win = vim.api.nvim_get_current_win()
        end)
        -- if the keymap spawns a floating window or fuzzy finder etc.
        -- the window switch doesn't work across the `nvim_buf_call`
        -- boundary
        if new_win ~= cur_win then
          vim.api.nvim_set_current_win(new_win)
        end
      end
    end
  end

  require('codecompanion.utils.keymaps')
    .new({
      bufnr = input_buf,
      callbacks = callbacks,
      data = chat,
      keymaps = filtered_keymaps,
    })
    :set()

  -- map the `send` keymap to our custom submit function
  local send = vim.deepcopy(config.interactions.chat.keymaps.send)
  if send then
    for mode, keys in pairs(send.modes) do
      if type(keys) ~= 'table' then
        keys = { keys }
      end
      for _, key in ipairs(keys) do
        vim.keymap.set(mode, key, function()
          M.submit(session)
        end, { buffer = input_buf, silent = true })
      end
    end
  end

  -- map the `codeblock` keymap to insert into the input buffer
  local codeblock = vim.deepcopy(config.interactions.chat.keymaps.codeblock)
  if codeblock then
    for mode, keys in pairs(codeblock.modes) do
      if type(keys) ~= 'table' then
        keys = { keys }
      end
      for _, key in ipairs(keys) do
        vim.keymap.set(mode, key, function()
          local bufnr = vim.api.nvim_get_current_buf()
          local cursor_pos = vim.api.nvim_win_get_cursor(0)
          local line = cursor_pos[1]
          local ft = chat.buffer_context.filetype or ''
          local block = {
            '````' .. ft,
            '',
            '````',
          }
          vim.api.nvim_buf_set_lines(bufnr, line - 1, line, false, block)
          vim.api.nvim_win_set_cursor(0, { line + 1, vim.fn.indent(line) })
        end, { buffer = input_buf, silent = true })
      end
    end
  end
end

---@param bufnr number
function M.setup_autocmds(bufnr)
  local group = vim.api.nvim_create_augroup('codecompanion-nui_input_' .. bufnr, { clear = true })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    buffer = bufnr,
    callback = function()
      M.refresh_placeholder(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = group,
    buffer = bufnr,
    callback = function()
      M.refresh_placeholder(bufnr)
    end,
  })
end

---@param bufnr number
function M.refresh_placeholder(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, NS_PLACEHOLDER, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 1 and lines[1] == '' then
    vim.api.nvim_buf_set_extmark(bufnr, NS_PLACEHOLDER, 0, 0, {
      virt_text = {
        { 'Type your message...', 'CcuiPlaceholder' },
      },
      virt_text_pos = 'overlay',
    })
  end
end

return M
