-- Monkey-patches codecompanion's completion system to work with input buffers.
--
-- The input buffer is a separate buffer from the chat buffer, but codecompanion's
-- completion, slash commands, and adapter lookups all key off the chat buffer
-- number. This module wraps three functions to transparently resolve input buffers
-- to their associated chat buffers:
--
--   cc.buf_get_chat         - chat lookup by buffer number
--   completion.interaction_type - returns "chat" for input buffers
--   completion.acp_commands - falls back to chat buffer for adapter cache
--
-- It also re-dispatches ChatAdapter/ChatModel events with the input buffer number
-- so the completion adapter cache gets populated for input buffers automatically.

local State = require('codecompanion-ui.state')

--- Resolve an input buffer number to its associated chat buffer number.
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
  if not session or not session.input_bufnr or session.chat_bufnr < 0 then
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

function M.setup()
  local ok_completion, completion = pcall(require, 'codecompanion.providers.completion')
  if not ok_completion then
    vim.notify('codecompanion-ui: codecompanion.providers.completion not found', vim.log.levels.WARN)
    return
  end

  local ok_cc, cc = pcall(require, 'codecompanion')
  if not ok_cc then
    vim.notify('codecompanion-ui: codecompanion not found', vim.log.levels.WARN)
    return
  end

  -- 1. Re-dispatch adapter/model events for input buffers so the completion
  --    adapter cache gets populated for them automatically.
  local aug = vim.api.nvim_create_augroup('codecompanion-ui_completion', { clear = true })

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
      if not session or not session.input_bufnr then
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
      if not session or not session.input_bufnr then
        return
      end

      vim.api.nvim_exec_autocmds('User', {
        pattern = 'CodeCompanionChatAdapter',
        data = { bufnr = session.input_bufnr, adapter = nil },
      })
    end,
  })

  -- 2. Wrap buf_get_chat to resolve input buffers -> chat buffers
  if cc.buf_get_chat then
    local original_buf_get_chat = cc.buf_get_chat
    cc.buf_get_chat = function(bufnr) ---@diagnostic disable-line: duplicate-set-field
      local result = original_buf_get_chat(bufnr)
      if result then
        return result
      end

      if bufnr then
        local chat_bufnr = resolve_chat_bufnr(bufnr)
        if chat_bufnr then
          return original_buf_get_chat(chat_bufnr)
        end
      end

      return nil
    end
  end

  -- 3. Wrap interaction_type to return "chat" for input buffers
  if completion.interaction_type then
    local original_interaction_type = completion.interaction_type
    completion.interaction_type = function(...) ---@diagnostic disable-line: duplicate-set-field
      if vim.bo.filetype == 'codecompanion_input' then
        return 'chat'
      end
      return original_interaction_type(...)
    end
  end

  -- 4. Wrap acp_commands to check chat buffer if input buffer has no adapter
  if completion.acp_commands then
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
end

return M
