-- modified from https://github.com/nvim-lua/lsp_extensions.nvim/blob/master/lua/lsp_extensions/inlay_hints.lua

local M = {}

local inlay_hints_ns = vim.api.nvim_create_namespace('lsp_extensions.inlay_hints')

function M.make_handler(fn)
  return function(...)
    local config_or_client_id = select(4, ...)
    local is_new = type(config_or_client_id) ~= 'number'
    if is_new then
      fn(...)
    else
      local err = select(1, ...)
      local method = select(2, ...)
      local result = select(3, ...)
      local client_id = select(4, ...)
      local bufnr = select(5, ...)
      local config = select(6, ...)
      fn(err, result, { method = method, client_id = client_id, bufnr = bufnr }, config)
    end
  end
end

function M.request(opts, bufnr)
  vim.lsp.buf_request(bufnr or 0, 'rust-analyzer/inlayHints', M.get_params(), M.get_callback(opts))
end

function M.get_callback(opts)
  opts = opts
    or {
      prefix = '  ',
      highlight = 'GitSignsCurrentLineBlame',
      enabled = { 'TypeHint', 'ChainingHint', 'ParameterHint' },
    }

  local highlight = opts.highlight or 'Comment'
  local prefix = opts.prefix or ' > '
  local aligned = opts.aligned or false

  local enabled = opts.enabled or { 'ChainingHint' }

  local only_current_line = opts.only_current_line
  if only_current_line == nil then
    only_current_line = false
  end

  return M.make_handler(function(err, result, ctx, _)
    -- I'm pretty sure this only happens for unsupported items.
    if err or type(result) == 'number' then
      return
    end

    if not result or vim.tbl_isempty(result) then
      return
    end

    vim.api.nvim_buf_clear_namespace(ctx.bufnr, inlay_hints_ns, 0, -1)

    local hint_store = {}

    local longest_line = -1

    -- Check if something is in the list
    -- in_list({"ChainingHint"})("ChainingHint")
    local in_list = function(list)
      return function(item)
        for _, f in ipairs(list) do
          if f == item then
            return true
          end
        end

        return false
      end
    end

    for _, hint in ipairs(result) do
      local finish = hint.range['end'].line
      if not hint_store[finish] and in_list(enabled)(hint.kind) then
        hint_store[finish] = hint

        if aligned then
          longest_line = math.max(longest_line, #vim.api.nvim_buf_get_lines(ctx.bufnr, finish, finish + 1, false)[1])
        end
      end
    end

    local display_virt_text = function(hint)
      local end_line = hint.range['end'].line

      -- Check for any existing / more important virtual text on the line.
      -- TODO: Figure out how stackable virtual text works? What happens if there is more than one??
      local existing_virt_text = vim.api.nvim_buf_get_extmarks(
        ctx.bufnr,
        inlay_hints_ns,
        { end_line, 0 },
        { end_line, 0 },
        {}
      )
      if not vim.tbl_isempty(existing_virt_text) then
        return
      end

      local text
      if aligned then
        local line_length = #vim.api.nvim_buf_get_lines(ctx.bufnr, end_line, end_line + 1, false)[1]
        text = string.format('%s %s', (' '):rep(longest_line - line_length), prefix .. hint.label)
      else
        text = prefix .. hint.label
      end
      vim.api.nvim_buf_set_virtual_text(ctx.bufnr, inlay_hints_ns, end_line, { { text, highlight } }, {})
    end

    if only_current_line then
      local hint = hint_store[vim.api.nvim_win_get_cursor(0)[1] - 1]

      if not hint then
        return
      else
        display_virt_text(hint)
      end
    else
      for _, hint in pairs(hint_store) do
        display_virt_text(hint)
      end
    end
  end)
end

function M.get_params()
  return { textDocument = vim.lsp.util.make_text_document_params() }
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, inlay_hints_ns, 0, -1)
end

function M.show(opts)
  opts = opts or {}
  vim.lsp.buf_request(0, 'rust-analyzer/inlayHints', M.get_params(), M.get_callback(opts))
end

return M
