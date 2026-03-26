local M = {}

local NS_PLACEHOLDER = vim.api.nvim_create_namespace('codecompanion-ui_placeholder')

-- Namespace used by codecompanion for virtual text (e.g. the initial prompt hint).
-- We clear this specifically rather than using namespace -1, which would wipe
-- extmarks from all plugins (treesitter, render-markdown, diagnostics, etc.).
local NS_CC_VIRTUAL_TEXT = vim.api.nvim_create_namespace('CodeCompanion-virtual_text')

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
  if not session or not session.input_bufnr or not vim.api.nvim_buf_is_valid(session.input_bufnr) then
    return
  end

  if session.is_processing then
    -- show a brief message in the winbar that we're still processing
    session.processing_blocked = true
    local Events = require('codecompanion-ui.events')
    Events.redraw_winbar(session)
    vim.defer_fn(function()
      -- Check that session and buffer are still valid before updating
      if session.input_bufnr and vim.api.nvim_buf_is_valid(session.input_bufnr) then
        session.processing_blocked = false
        Events.redraw_winbar(session)
      end
    end, 1500)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(session.input_bufnr, 0, -1, false)
  local text = vim.trim(table.concat(lines, '\n'))
  if text == '' then
    return
  end

  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  -- Clear input buffer before submitting
  vim.api.nvim_buf_set_lines(session.input_bufnr, 0, -1, false, { '' })
  M.refresh_placeholder(session.input_bufnr)

  chat.ui:unlock_buf()
  local line_count = vim.api.nvim_buf_line_count(chat.bufnr)
  local text_lines = vim.split(text, '\n', { plain = true })
  vim.api.nvim_buf_set_lines(chat.bufnr, line_count, line_count, false, text_lines)

  -- Clear codecompanion's virtual text (e.g. initial prompt placeholder) from
  -- blank lines in the chat buffer using the specific namespace.
  vim.api.nvim_buf_clear_namespace(chat.bufnr, NS_CC_VIRTUAL_TEXT, 0, -1)

  -- Scroll chat to bottom and re-engage autoscroll
  session.chat_at_bottom = true
  if vim.api.nvim_win_is_valid(session.chat_winid) then
    local chat_line_count = vim.api.nvim_buf_line_count(session.chat_bufnr)
    pcall(vim.api.nvim_win_set_cursor, session.chat_winid, { chat_line_count, 0 })
  end

  local ok, err = pcall(chat.submit, chat)
  if not ok then
    -- Restore the input buffer content so the user's message isn't lost
    vim.api.nvim_buf_set_lines(session.input_bufnr, 0, -1, false, text_lines)
    M.refresh_placeholder(session.input_bufnr)
    -- Stop spinner and clear processing state so user isn't stuck
    local Events = require('codecompanion-ui.events')
    Events.stop_spinner(session)
    vim.notify(string.format('codecompanion-ui: submit failed: %s', err), vim.log.levels.ERROR)
  end
end

---@param session CcuiSession
function M.setup_keymaps(session)
  local input_buf = session.input_bufnr

  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return
  end

  -- Apply codecompanion's chat keymaps to the input buffer, except 'send' and
  -- 'codeblock' which we override with our own implementations.
  local cc_config = require('codecompanion.config')
  local cc_keymaps = vim.deepcopy(cc_config.interactions.chat.keymaps)
  local filtered_keymaps = {}
  for name, keymap in pairs(cc_keymaps) do
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
          return
        end
        local cur_win = vim.api.nvim_get_current_win()
        local new_win
        local args = { ... }
        vim.api.nvim_buf_call(session.chat_bufnr, function()
          callback.callback(unpack(args))
          new_win = vim.api.nvim_get_current_win()
        end)
        -- If the keymap spawns a floating window or fuzzy finder, the window
        -- switch doesn't propagate across the nvim_buf_call boundary.
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

  -- Map the 'send' keymap to our custom submit function
  local send = vim.deepcopy(cc_config.interactions.chat.keymaps.send)
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

  -- Map the 'codeblock' keymap to insert into the input buffer.
  -- Uses 4 backticks so that code blocks containing triple backticks
  -- (e.g. markdown examples) are correctly nested.
  local codeblock = vim.deepcopy(cc_config.interactions.chat.keymaps.codeblock)
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

  -- Mirror approval prompt keymaps onto the input buffer. The approval prompt
  -- sets keymaps only on the chat buffer, so they're unreachable when the user
  -- is focused here. We forward each keypress to the chat buffer so the
  -- original closures fire as normal.
  local approval_group = vim.api.nvim_create_augroup('codecompanion-ui_approval_' .. input_buf, { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = approval_group,
    pattern = 'CodeCompanionToolApprovalRequested',
    callback = function(args)
      local data = args.data or {}
      if data.bufnr ~= session.chat_bufnr then
        return
      end

      local shared_keymaps = cc_config.interactions.shared.keymaps
      local chat_keymaps = cc_config.interactions.chat.keymaps
      local keys = {}
      for _, name in ipairs({ 'always_accept', 'accept_change', 'reject_change', 'cancel', 'view_diff' }) do
        local km = chat_keymaps[name] or shared_keymaps[name]
        if km and km.modes and km.modes.n then
          table.insert(keys, km.modes.n)
        end
      end

      for _, key in ipairs(keys) do
        vim.keymap.set('n', key, function()
          if not vim.api.nvim_win_is_valid(session.chat_winid) then
            return
          end
          local orig_win = vim.api.nvim_get_current_win()
          local new_win
          vim.api.nvim_set_current_win(session.chat_winid)
          vim.api.nvim_feedkeys(key, 'm', true)
          vim.schedule(function()
            new_win = vim.api.nvim_get_current_win()
            -- if the new window is neither the chat buffer or input buffer,
            -- its the "view diff" floating window
            if new_win ~= session.chat_winid and new_win ~= orig_win then
              -- stay in the floating window, and refocus input buffer on window close
              vim.api.nvim_create_autocmd('WinClosed', {
                group = approval_group,
                pattern = tostring(new_win),
                once = true,
                callback = function()
                  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
                    vim.api.nvim_set_current_win(session.input_winid)
                  end
                end,
              })
              return
            end
            if vim.api.nvim_win_is_valid(orig_win) then
              vim.api.nvim_set_current_win(orig_win)
            end
          end)
        end, { buffer = input_buf, silent = true, nowait = true })
      end

      session.approval_keymaps = keys
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = approval_group,
    pattern = 'CodeCompanionToolApprovalFinished',
    callback = function(args)
      local data = args.data or {}
      if data.bufnr ~= session.chat_bufnr or not session.approval_keymaps then
        return
      end
      for _, key in ipairs(session.approval_keymaps) do
        pcall(vim.keymap.del, 'n', key, { buffer = input_buf })
      end
      session.approval_keymaps = nil
    end,
  })

  -- Clean up approval keymaps if buffer is deleted before approval finishes
  vim.api.nvim_create_autocmd('BufDelete', {
    group = approval_group,
    buffer = input_buf,
    callback = function()
      if session.approval_keymaps then
        for _, key in ipairs(session.approval_keymaps) do
          pcall(vim.keymap.del, 'n', key, { buffer = input_buf })
        end
        session.approval_keymaps = nil
      end
    end,
  })
end

---@param bufnr number
function M.setup_autocmds(bufnr)
  local group = vim.api.nvim_create_augroup('codecompanion-ui_input_' .. bufnr, { clear = true })

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
    local config = require('codecompanion-ui.config')
    vim.api.nvim_buf_set_extmark(bufnr, NS_PLACEHOLDER, 0, 0, {
      virt_text = {
        { config.input.placeholder, 'CcuiPlaceholder' },
      },
      virt_text_pos = 'overlay',
    })
  end
end

return M
