local window = require('my.utils.window')

-- https://github.com/olimorris/codecompanion.nvim/discussions/640#discussioncomment-12866279
local Spinner = {
  processing = false,
  spinner_index = 1,
  namespace_id = nil,
  timer = nil,
  spinner_symbols = {
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  },
  filetype = 'codecompanion',
}

function Spinner:get_buf(filetype)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == filetype then
      return buf
    end
  end
  return nil
end

function Spinner:update_spinner()
  if not self.processing then
    self:stop_spinner()
    return
  end

  self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1

  local buf = self:get_buf(self.filetype)
  if buf == nil then
    return
  end

  -- Clear previous virtual text
  vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)

  local last_line = vim.api.nvim_buf_line_count(buf) - 1
  vim.api.nvim_buf_set_extmark(buf, self.namespace_id, last_line, 0, {
    virt_lines = { { { self.spinner_symbols[self.spinner_index] .. ' Thinking...', 'Comment' } } },
    virt_lines_above = true, -- false means below the line
  })
end

function Spinner:start_spinner()
  self.processing = true
  self.spinner_index = 0

  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end

  self.timer = vim.loop.new_timer()
  self.timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      self:update_spinner()
    end)
  )
end

function Spinner:stop_spinner()
  self.processing = false

  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end

  local buf = self:get_buf(self.filetype)
  if buf == nil then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
end

function Spinner:init()
  -- Create namespace for virtual text
  self.namespace_id = vim.api.nvim_create_namespace('CodeCompanionSpinner')

  vim.api.nvim_create_augroup('CodeCompanionHooks', { clear = true })
  local group = vim.api.nvim_create_augroup('CodeCompanionHooks', {})

  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequest*',
    group = group,
    callback = function(request)
      if request.match == 'CodeCompanionRequestStarted' then
        self:start_spinner()
      elseif request.match == 'CodeCompanionRequestFinished' then
        self:stop_spinner()
      end
    end,
  })
end

local copilot = {
  name = 'copilot',
  model = 'gpt-5-codex',
}

return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'folke/snacks.nvim' },
    {
      'zbirenbaum/copilot.lua',
      event = 'LspAttach',
      cmd = 'Copilot',
      config = {
        copilot_model = 'gpt-5-codex',
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<C-CR>',
            accept_line = '<C-t>',
            next = '<C-n>',
            prev = '<C-p>',
            dismiss = '<C-d>',
          },
        },
        server_opts_overrides = {
          settings = {
            telemetry = {
              telemetryLevel = 'off',
            },
          },
        },
      },
    },
  },
  version = false,
  cmd = {
    'CodeCompanionChat',
    'CodeCompanionInline',
    'CodeCompanionRefactor',
    'CodeCompanionNew',
    'CodeCompanionClear',
    'CodeCompanionToggle',
  },
  keys = {
    {
      '<leader>aa',
      function()
        require('codecompanion').chat()
      end,
      desc = 'codecompanion: chat',
      mode = { 'n', 'v' },
    },
    { '<leader>ae', desc = 'codecompanion: edit', mode = { 'v' } },
    { '<leader>aB', desc = 'codecompanion: add all open buffers' },
    { '<leader>ac', desc = 'codecompanion: add current buffer' },
    { '<leader>aC', desc = 'codecompanion: toggle selection' },
    {
      '<leader>af',
      function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'codecompanion' and not window.is_floating_window(win) then
            vim.api.nvim_set_current_win(win)
          end
        end
      end,
      desc = 'codecompanion: focus',
    },
    { '<leader>ah', desc = 'codecompanion: select history' },
    { '<leader>an', desc = 'codecompanion: new chat' },
    {
      '<leader>at',
      function()
        require('codecompanion').toggle()
      end,
      desc = 'CodeCompanion: toggle',
    },
  },
  opts = {
    strategies = {
      chat = {
        keymaps = {
          -- change this mapping because I use gx to open URLs
          clear = {
            modes = { n = 'gX' },
          },
          send = {
            -- to hook up the loading spinner
            callback = function(chat)
              vim.cmd.stopinsert()
              chat:submit()
              chat:add_buf_message({ role = 'llm', content = '' })
            end,
          },
        },
        adapter = copilot,
      },
      inline = {
        adapter = copilot,
      },
      cmd = {
        adapter = copilot,
      },
    },
  },
  config = function(_, opts)
    Spinner:init()
    require('codecompanion').setup(opts)
  end,
}
