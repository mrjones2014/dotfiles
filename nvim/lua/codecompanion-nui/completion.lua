local M = {}

--- Wrap codecompanion's completion functions to work with input buffers
function M.setup()
  local completion = require('codecompanion.providers.completion')

  -- Wrap acp_commands to check chat buffer if input buffer has no adapter
  local original_acp_commands = completion.acp_commands
  completion.acp_commands = function(bufnr) ---@diagnostic disable-line: duplicate-set-field
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Try the original function first
    local result = original_acp_commands(bufnr)
    if #result > 0 then
      return result
    end

    -- If empty and this is an input buffer, try the chat buffer
    local session = require('codecompanion-nui.state').get_by_input_bufnr(bufnr)
    if session and session.chat_bufnr > 0 then
      return original_acp_commands(session.chat_bufnr)
    end

    return {}
  end
end

return M
