M = {}

-- lines to show above and below definition
local context_before = 0
local context_after = 10

local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then
    return nil
  end
  local range = result[1].targetRange or result[1].range
  range.start.line = (range.start.line - context_before)
  range['end'].line = (range['end'].line + context_after)
  vim.lsp.util.preview_location(result[1], { style = 'numbered', border = 'rounded' })
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

return M
