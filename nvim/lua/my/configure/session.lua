return {
  'stevearc/resession.nvim',
  event = 'VeryLazy',
  init = function()
    local function get_session_name()
      local name = vim.fn.getcwd()
      local branch = vim.fn.system('git branch --show-current')
      if vim.v.shell_error == 0 then
        return name .. branch
      else
        return name
      end
    end

    -- Only load the session if nvim was started with no args, or if command was to open a directory, not a file
    local num_args = vim.fn.argc(-1)
    if num_args == 0 or (num_args == 1 and vim.fn.isdirectory(vim.fn.argv(0) or '') ~= 0) then
      require('resession').load(get_session_name(), { dir = 'dirsession', silence_errors = true, notify = false })
    end

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        require('resession').save(get_session_name(), { dir = 'dirsession', notify = false })
      end,
    })
  end,
  opts = {
    autosave = { enabled = true },
  },
}
