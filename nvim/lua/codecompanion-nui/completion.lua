local State = require('codecompanion-nui.state')

--- Resolve an input buffer number to its associated chat buffer number.
--- Returns nil if bufnr is not an input buffer.
---@param bufnr number
---@return number|nil
local function resolve_chat_bufnr(bufnr)
  -- Fast path: check buffer variable set in layout.lua
  local chat_bufnr = vim.b[bufnr] and vim.b[bufnr].codecompanion_chat_bufnr
  if chat_bufnr and chat_bufnr > 0 then
    return chat_bufnr
  end

  -- Fallback: check session state
  local session = State.get_by_input_bufnr(bufnr)
  if session and session.chat_bufnr > 0 then
    return session.chat_bufnr
  end

  return nil
end

local M = {}

--- Fire a synthetic ChatAdapter event for an input buffer.
--- Called from events.lua after layout.attach() creates the input buffer.
---@param session CcuiSession
function M.backfill_adapter_cache(session)
  if not session or session.input_bufnr < 0 or session.chat_bufnr < 0 then
    return
  end

  local cc = require('codecompanion')
  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat or not chat.adapter then
    return
  end

  local adapters = require('codecompanion.adapters')
  vim.api.nvim_exec_autocmds('User', {
    pattern = 'CodeCompanionChatAdapter',
    data = {
      bufnr = session.input_bufnr,
      adapter = adapters.make_safe(chat.adapter),
    },
  })
end

--- Wrap codecompanion's completion functions to work with input buffers
function M.setup()
  local completion = require('codecompanion.providers.completion')
  local cc = require('codecompanion')

  -- 1. Re-dispatch adapter/model events for input buffers so adapter_cache
  --    gets populated for them automatically.
  local aug = vim.api.nvim_create_augroup('codecompanion-nui_completion', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = aug,
    pattern = { 'CodeCompanionChatAdapter', 'CodeCompanionChatModel' },
    callback = function(args)
      local data = args.data or {}
      if not data.bufnr then
        return
      end

      -- Only act on chat buffers that have an associated input buffer
      local session = State.get_by_bufnr(data.bufnr)
      if not session or session.input_bufnr < 0 then
        return
      end

      -- Re-emit the same event with input buffer number
      local new_data = vim.deepcopy(data)
      new_data.bufnr = session.input_bufnr
      vim.api.nvim_exec_autocmds('User', {
        pattern = args.match,
        data = new_data,
      })
    end,
  })

  -- Clean up input buffer adapter_cache entry when chat closes
  vim.api.nvim_create_autocmd('User', {
    group = aug,
    pattern = 'CodeCompanionChatClosed',
    callback = function(args)
      local data = args.data or {}
      if not data.bufnr then
        return
      end

      local session = State.get_by_bufnr(data.bufnr)
      if not session or session.input_bufnr < 0 then
        return
      end

      vim.api.nvim_exec_autocmds('User', {
        pattern = 'CodeCompanionChatAdapter',
        data = { bufnr = session.input_bufnr, adapter = nil },
      })
    end,
  })

  -- 2. Wrap buf_get_chat to resolve input buffers → chat buffers
  local original_buf_get_chat = cc.buf_get_chat
  cc.buf_get_chat = function(bufnr)
    local result = original_buf_get_chat(bufnr)
    if result then
      return result
    end

    -- If not found and this is an input buffer, try the chat buffer
    if bufnr then
      local chat_bufnr = resolve_chat_bufnr(bufnr)
      if chat_bufnr then
        return original_buf_get_chat(chat_bufnr)
      end
    end

    return nil
  end

  -- 3. Wrap interaction_type to return "chat" for input buffers
  local original_interaction_type = completion.interaction_type
  completion.interaction_type = function(...) ---@diagnostic disable-line: duplicate-set-field
    if vim.bo.filetype == 'codecompanion_input' then
      return 'chat'
    end
    return original_interaction_type(...)
  end

  -- 4. Wrap acp_commands to check chat buffer if input buffer has no adapter
  local original_acp_commands = completion.acp_commands
  completion.acp_commands = function(bufnr, ...) ---@diagnostic disable-line: duplicate-set-field
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local result = original_acp_commands(bufnr, ...)
    if #result > 0 then
      return result
    end

    local chat_bufnr = resolve_chat_bufnr(bufnr)
    if chat_bufnr then
      return original_acp_commands(chat_bufnr, ...)
    end

    return {}
  end
end

return M
