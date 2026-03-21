local state = require('ccui.state')

local M = {}

--- Format a token count for display
---@param tokens number
---@return string
local function format_tokens(tokens)
  if tokens >= 1000 then
    return string.format('%.1fk', tokens / 1000)
  end
  return tostring(tokens)
end

--- Evaluate the winbar string for the input window.
--- Called via v:lua from the winbar option.
---@return string
function M.eval()
  local session = state.active()
  if not session then
    return ''
  end

  local ok, cc = pcall(require, 'codecompanion')
  if not ok then
    return ''
  end

  local chat = cc.buf_get_chat(session.chat_bufnr)
  if not chat then
    return ''
  end

  local parts = {}

  -- Context items (attached buffers/files) - show file names
  if chat.context_items and #chat.context_items > 0 then
    local context_names = {}
    for _, item in ipairs(chat.context_items) do
      -- Extract filename from path if available
      if item.opts and item.opts.bufnr then
        local bufname = vim.api.nvim_buf_get_name(item.opts.bufnr)
        local filename = vim.fn.fnamemodify(bufname, ':t')
        if filename ~= '' then
          table.insert(context_names, filename)
        end
      elseif item.opts and item.opts.path then
        local filename = vim.fn.fnamemodify(item.opts.path, ':t')
        if filename ~= '' then
          table.insert(context_names, filename)
        end
      end
    end
    if #context_names > 0 then
      local display = #context_names <= 2 and table.concat(context_names, ', ')
        or string.format('%s, +%d more', context_names[1], #context_names - 1)
      table.insert(parts, string.format('%%#CcuiContextBufs#󰈔 %s', display))
    end
  end

  -- Tools
  local tool_names = {}
  if chat.tool_registry and chat.tool_registry.schemas then
    for _, schema in ipairs(chat.tool_registry.schemas) do
      if schema.function_obj and schema.function_obj.name then
        table.insert(tool_names, schema.function_obj.name)
      end
    end
  end
  if #tool_names > 0 then
    local display = #tool_names <= 2 and table.concat(tool_names, ', ')
      or string.format('%s, +%d', tool_names[1], #tool_names - 1)
    table.insert(parts, string.format('%%#CcuiContextTools#󰭻 %s', display))
  end

  -- Tokens
  if chat.tokens and chat.tokens > 0 then
    table.insert(parts, string.format('%%#CcuiContextTokens#󰊖 %s', format_tokens(chat.tokens)))
  end

  if #parts == 0 then
    return ''
  end

  return table.concat(parts, ' %#CcuiContextSep#│ ')
end

--- Set the winbar on the input window
---@param winid number
function M.set(winid)
  if vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].winbar = "%{%v:lua.require('ccui.context').eval()%}"
  end
end

--- Redraw the context bar for a session's input window
---@param session ccui.Session
function M.redraw(session)
  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_win_call(session.input_winid, function()
      vim.cmd('redrawstatus')
    end)
  end
end

return M
