local State = require('codecompanion-nui.state')

local M = {}

local AUGROUP = 'codecompanion-nui'

local is_processing = false
local spinner_idx = 1
---@type uv.uv_timer_t|nil
local spinner_timer = nil

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
        require('codecompanion-nui.layout').attach(data.bufnr, data.id)
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
      require('codecompanion-nui.layout').detach(data.id)
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
      require('codecompanion-nui.layout').detach(data.id)
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

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatAdapter',
    callback = function() end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatModel',
    callback = function() end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CodeCompanionChatACPModeChanged',
    callback = function() end,
  })
end

---@param session CcuiSession
function M.start_spinner(session)
  is_processing = true
  spinner_idx = 1

  if spinner_timer then
    return
  end

  spinner_timer = assert(vim.uv.new_timer())
  spinner_timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if not is_processing then
        return
      end
      local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
      spinner_idx = (spinner_idx % #spinner_frames) + 1
      if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
        vim.api.nvim_win_call(session.input_winid, function()
          vim.cmd('redrawstatus')
        end)
      end
    end)
  )
end

---@param session CcuiSession
function M.stop_spinner(session)
  is_processing = false
  spinner_idx = 1

  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
  end

  if session.input_winid and vim.api.nvim_win_is_valid(session.input_winid) then
    vim.api.nvim_win_call(session.input_winid, function()
      vim.cmd('redrawstatus')
    end)
  end
end

---@return boolean
function M.is_processing()
  return is_processing
end

---@return number
function M.get_spinner_idx()
  return spinner_idx
end

return M
