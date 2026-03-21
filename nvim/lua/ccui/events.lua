local State = require('ccui.state')

local M = {}

local AUGROUP = 'ccui'

---Register all CodeCompanion autocmd handlers
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
      vim.schedule(function()
        require('ccui.layout').attach(data.bufnr, data.id)
      end)
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
      require('ccui.layout').detach(data.id)
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
      require('ccui.layout').detach(data.id)
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
      require('ccui.winbar').refresh_metadata(session)
      require('ccui.winbar').redraw(session)
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

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatAdapter',
    callback = function(args)
      local data = args.data or {}
      local session = data.id and State.get(data.id)
      if not session then
        return
      end
      if data.adapter then
        session.adapter_name = data.adapter.formatted_name or data.adapter.name or session.adapter_name
      end
      require('ccui.winbar').redraw(session)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatModel',
    callback = function(args)
      local data = args.data or {}
      local session = data.id and State.get(data.id)
      if not session then
        return
      end
      if data.model then
        session.model_name = data.model
      end
      require('ccui.winbar').redraw(session)
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatACPModeChanged',
    callback = function()
      local session = State.active()
      if session then
        require('ccui.winbar').refresh_metadata(session)
        require('ccui.winbar').redraw(session)
      end
    end,
  })
end

---Start the spinner animation for a session
---@param session ccui.Session
function M.start_spinner(session)
  session.is_processing = true
  session.spinner_idx = 1

  if session.timer then
    return
  end

  session.timer = vim.uv.new_timer()
  session.timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if not session.is_processing then
        return
      end
      session.spinner_idx = (session.spinner_idx % #State.spinner_frames) + 1
      if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
        vim.api.nvim_win_call(session.input_winid, function()
          vim.cmd('redrawstatus')
        end)
      end
    end)
  )
end

---Stop the spinner animation for a session
---@param session ccui.Session
function M.stop_spinner(session)
  session.is_processing = false
  session.spinner_idx = 1

  if session.timer then
    session.timer:stop()
    session.timer:close()
    session.timer = nil
  end

  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_win_call(session.input_winid, function()
      vim.cmd('redrawstatus')
    end)
  end
end

return M
