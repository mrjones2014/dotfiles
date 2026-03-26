local State = require('codecompanion-ui.state')

local M = {}

local AUGROUP = 'codecompanion-ui'

function M.setup()
  local group = vim.api.nvim_create_augroup(AUGROUP, { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatOpened',
    callback = function(args)
      local data = args.data or {}
      if not data.bufnr or not data.id then
        return
      end
      require('codecompanion-ui.layout').attach(data.bufnr, data.id)
      -- Backfill adapter cache for the newly created input buffer.
      -- ChatAdapter fires before ChatOpened, so the input buffer didn't
      -- exist when the adapter cache was originally populated.
      local session = State.get(data.id)
      if session then
        require('codecompanion-ui.completion').backfill_adapter_cache(session)
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatHidden',
    callback = function(args)
      local data = args.data or {}
      if not data.id then
        return
      end
      require('codecompanion-ui.layout').detach(data.id)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatClosed',
    callback = function(args)
      local data = args.data or {}
      if not data.id then
        return
      end
      require('codecompanion-ui.layout').detach(data.id)
      State.remove(data.id)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatSubmitted',
    callback = function(args)
      local data = args.data or {}
      local session = data.id and State.get(data.id)
      if not session then
        return
      end
      M.start_spinner(session)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatDone',
    callback = function(args)
      local data = args.data or {}
      local session = data.id and State.get(data.id)
      if not session then
        return
      end
      M.stop_spinner(session)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatStopped',
    callback = function(args)
      local data = args.data or {}
      local session = data.id and State.get(data.id)
      if not session then
        return
      end
      M.stop_spinner(session)
    end,
  })
end

---@param session CcuiSession
function M.redraw_winbar(session)
  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_win_call(session.input_winid, function()
      vim.cmd('redrawstatus')
    end)
  end
end

---@param session CcuiSession
function M.start_spinner(session)
  session.is_processing = true
  session.spinner_idx = 1

  if session.spinner_timer then
    return
  end

  local config = require('codecompanion-ui.config')

  local timer = vim.uv.new_timer()
  if not timer then
    vim.notify('codecompanion-ui: failed to create spinner timer', vim.log.levels.WARN)
    return
  end

  session.spinner_timer = timer
  session.spinner_timer:start(
    0,
    config.spinner.interval_ms,
    vim.schedule_wrap(function()
      if not session.is_processing then
        return
      end
      local frames = config.spinner.frames
      session.spinner_idx = (session.spinner_idx % #frames) + 1
      M.redraw_winbar(session)
    end)
  )
end

---@param session CcuiSession
function M.stop_spinner(session)
  session.is_processing = false
  session.spinner_idx = 1

  if session.spinner_timer then
    session.spinner_timer:stop()
    session.spinner_timer:close()
    session.spinner_timer = nil
  end

  M.redraw_winbar(session)
end

return M
