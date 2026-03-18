local conditions = require('heirline.conditions')
local utils = require('heirline.utils')
local my_conditions = require('my.configure.heirline.conditions')
local sep = require('my.configure.heirline.separators')

local special_filenames = { 'mod.rs', 'lib.rs', 'init.lua' }

local function get_current_filenames()
  local listed_buffers = vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(bufnr)
      return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr)
    end)
    :totable()

  return vim.iter(listed_buffers):map(vim.api.nvim_buf_get_name):totable()
end

-- Get unique name for the current buffer
local function get_unique_filename(filename)
  local filenames = vim
    .iter(get_current_filenames())
    :filter(function(filename_other)
      return filename_other ~= filename
    end)
    :map(string.reverse)
    :totable() -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)

  local index

  -- For every other filename, compare it with the name of the current file char-by-char to
  -- find the minimum index `i` where the i-th character is different for the two filenames
  -- After doing it for every filename, get the maximum value of `i`
  if next(filenames) then
    index = math.max(unpack(vim
      .iter(filenames)
      :map(function(filename_other)
        for i = 1, #filename do
          -- Compare i-th character of both names until they aren't equal
          if filename:sub(i, i) ~= filename_other:sub(i, i) then
            return i
          end
        end
        return 1
      end)
      :totable()))
  else
    index = 1
  end

  -- Iterate backwards (since filename is reversed) until a "/" is found
  -- in order to show a valid file path
  while index <= #filename do
    if filename:sub(index, index) == '/' then
      index = index - 1
      break
    end

    index = index + 1
  end

  local result = string.reverse(string.sub(filename, 1, index))
  -- for special filenames like `lib.rs`, `mod.rs`, `index.ts` etc.
  -- always show at least one parent
  if vim.iter(ipairs(special_filenames)):any(function(_, special)
    return special == result
  end) then
    local parts = vim.split(string.reverse(filename), '/')
    -- if parent is just `src` then show another parent
    if parts[#parts - 1] == 'src' then
      return table.concat({ parts[#parts - 2], parts[#parts - 1], parts[#parts] }, '/')
    end
    return table.concat({ parts[#parts - 1], parts[#parts] }, '/')
  end
  return result
end

local M = {}

M.UniqueFilename = {
  init = function(self)
    self.bufname = get_unique_filename(vim.api.nvim_buf_get_name(0))
  end,
  {
    condition = function(self)
      return my_conditions.should_show_filename(self.bufname)
    end,
    provider = function(self)
      return string.format(' %s ', self.bufname)
    end,
    hl = { bg = 'base' },
  },
  {
    -- file save status indicator
    condition = function()
      return vim.bo.modified == true
    end,
    provider = ' ',
    hl = { bg = 'base' },
  },
  {
    provider = sep.rounded_right,
    hl = function()
      return { bg = conditions.has_diagnostics() and 'surface1' or 'surface0', fg = 'base' }
    end,
  },
}

local diagnostics_order = {
  vim.diagnostic.severity.HINT,
  vim.diagnostic.severity.INFO,
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

local severity_name = {
  [vim.diagnostic.severity.HINT] = 'Hint',
  [vim.diagnostic.severity.INFO] = 'Info',
  [vim.diagnostic.severity.WARN] = 'Warn',
  [vim.diagnostic.severity.ERROR] = 'Error',
}

M.Diagnostics = {
  provider = ' ',
  hl = { bg = 'surface1' },
  condition = conditions.has_diagnostics,
  {
    update = { 'DiagnosticChanged', 'BufEnter' },
    init = function(self)
      self.counts = vim.diagnostic.count(0)
    end,
    unpack(vim
      .iter(diagnostics_order)
      :map(function(severity)
        return {
          provider = function(self)
            local sign = vim.diagnostic.config().signs.text[severity]
            return string.format('%s%s ', sign, self.counts[severity] or 0)
          end,
          condition = function(self)
            return (self.counts[severity] or 0) > 0
          end,
          hl = function()
            return {
              fg = utils.get_highlight(string.format('DiagnosticSign%s', severity_name[severity])).fg,
              bg = 'surface1',
            }
          end,
        }
      end)
      :totable()),
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'surface1', bg = 'surface0' },
  },
}

-- taken from https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md
M.Navic = {
  condition = function()
    return conditions.lsp_attached() and require('nvim-navic').is_available()
  end,
  static = {
    -- create a type highlight map
    type_hl = {
      File = 'Directory',
      Module = '@include',
      Namespace = '@namespace',
      Package = '@include',
      Class = '@structure',
      Method = '@method',
      Property = '@property',
      Field = '@field',
      Constructor = '@constructor',
      Enum = '@field',
      Interface = '@type',
      Function = '@function',
      Variable = '@variable',
      Constant = '@constant',
      String = '@string',
      Number = '@number',
      Boolean = '@boolean',
      Array = '@field',
      Object = '@type',
      Key = '@keyword',
      Null = '@comment',
      EnumMember = '@field',
      Struct = '@structure',
      Event = '@keyword',
      Operator = '@operator',
      TypeParameter = '@type',
    },
    -- bit operation dark magic, see below...
    enc = function(line, col, winnr)
      return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
    end,
    -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
    dec = function(c)
      local line = bit.rshift(c, 16)
      local col = bit.band(bit.rshift(c, 6), 1023)
      local winnr = bit.band(c, 63)
      return line, col, winnr
    end,
  },
  init = function(self)
    local data = require('nvim-navic').get_data() or {}
    local children = {}
    -- create a child for each level
    for i, d in ipairs(data) do
      -- encode line and column numbers into a single integer
      local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
      local child = {
        {
          provider = d.icon,
          hl = self.type_hl[d.type],
        },
        {
          -- escape `%`s (elixir) and buggy default separators
          provider = d.name:gsub('%%', '%%%%'):gsub('%s*->%s*', ''),
          -- highlight icon only or location name as well
          hl = self.type_hl[d.type],

          on_click = {
            -- pass the encoded position through minwid
            minwid = pos,
            callback = function(_, minwid)
              -- decode
              local line, col, winnr = self.dec(minwid)
              vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
            end,
            name = 'heirline_navic',
          },
        },
      }
      -- add a separator only if needed
      if #data > 1 and i < #data then
        table.insert(child, {
          provider = ' > ',
        })
      end
      table.insert(children, child)
    end
    -- instantiate the new child, overwriting the previous one
    self.child = self:new(children, 1)
  end,
  -- evaluate the children containing navic components
  provider = function(self)
    return string.format(' %s', self.child:eval())
  end,
  update = 'CursorMoved',
}

M.FilePosition = {
  init = function(self)
    self.bufname = vim.api.nvim_buf_get_name(0)
  end,
  static = {
    sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' },
  },
  provider = '',
  {
    condition = function(self)
      return my_conditions.should_show_filename(self.bufname)
    end,
    provider = ' 󰉸 %l/%3L% ',
    hl = { bg = 'surface0' },
  },
  {
    condition = function(self)
      return my_conditions.should_show_filename(self.bufname)
    end,
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
      return string.format(' %s ', string.rep(self.sbar[i], 2))
    end,
    hl = { bg = 'surface0', fg = 'blue' },
  },
}

local codecompanion_state = {
  is_processing = false,
  spinner_idx = 1,
  timer = nil,
}

local CodeCompanionMode = {
  init = function(self)
    local chat = require('codecompanion').buf_get_chat(0)
    if chat and chat.acp_connection and chat.acp_connection._modes then
      local modes = chat.acp_connection._modes
      local current_mode_id = modes and modes.currentModeId or ''

      -- Find the full mode info
      for _, mode in ipairs(modes and modes.availableModes or {}) do
        if mode.id == current_mode_id then
          self.mode_name = mode.name
          self.mode_id = mode.id
          break
        end
      end
    end

    self.mode_name = self.mode_name or 'Default'
    if self.mode_name == 'Default' then
      self.mode_name = 'Build Mode'
    end
    self.mode_id = self.mode_id or 'default'
  end,
  static = {
    mode_icons = {
      default = '󰙨',
      acceptEdits = '󰄬',
      plan = '󰓅',
      dontAsk = '󰛑',
      bypassPermissions = '󰒃',
    },
  },
  {
    provider = sep.rounded_left,
    hl = { fg = 'surface2', bg = 'surface0' },
  },
  {
    provider = function(self)
      local icon = self.mode_icons[self.mode_id] or '󰙨'
      return string.format(' %s %s ', icon, self.mode_name)
    end,
    hl = { bg = 'surface2', fg = 'blue', bold = true },
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'surface2', bg = 'surface1' },
  },
}

local CodeCompanionAdapter = {
  init = function(self)
    local chat = require('codecompanion').buf_get_chat(0)
    if chat and chat.adapter then
      self.adapter_name = chat.adapter.formatted_name or chat.adapter.name or 'Unknown'
    else
      self.adapter_name = 'Unknown'
    end
  end,
  {
    provider = function(self)
      return string.format('  %s ', self.adapter_name)
    end,
    hl = { bg = 'surface1', fg = 'cyan' },
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'surface1', bg = 'base' },
  },
}

local CodeCompanionModel = {
  init = function(self)
    local chat = require('codecompanion').buf_get_chat(0)
    if chat and chat.acp_connection and chat.acp_connection._models then
      local models = chat.acp_connection._models
      local current_model_id = models and models.currentModelId or 'Default'

      -- Find the full model info
      for _, model in ipairs(models and models.availableModels or {}) do
        if model.modelId == current_model_id then
          self.model_name = model.name
          break
        end
      end
    end

    self.model_name = self.model_name or 'Default'
  end,
  {
    provider = function(self)
      return string.format(' 󰧑 %s ', self.model_name)
    end,
    hl = { bg = 'base', fg = 'green' },
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'base', bg = 'surface0' },
  },
}

local CodeCompanionSpinner = {
  static = {
    spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  },
  {
    condition = function()
      return codecompanion_state.is_processing
    end,
    {
      provider = function(self)
        return string.format(' %s Processing... ', self.spinner_frames[codecompanion_state.spinner_idx])
      end,
      hl = { bg = 'surface0', fg = 'yellow', bold = true },
    },
  },
}

-- Setup autocmds to manage spinner state
local function setup_codecompanion_autocmds()
  local aug = vim.api.nvim_create_augroup('HeirlineCodeCompanion', { clear = true })

  -- Start spinner on chat adapter request
  vim.api.nvim_create_autocmd('User', {
    group = aug,
    pattern = 'CodeCompanionChatSubmitted',
    callback = function()
      codecompanion_state.is_processing = true

      -- Start spinner timer if not already running
      if not codecompanion_state.timer then
        codecompanion_state.timer = vim.uv.new_timer()
        codecompanion_state.timer:start(
          0,
          100,
          vim.schedule_wrap(function()
            codecompanion_state.spinner_idx = (codecompanion_state.spinner_idx % 10) + 1
            vim.cmd('redrawstatus')
          end)
        )
      end
    end,
  })

  -- Stop spinner on chat completion
  vim.api.nvim_create_autocmd('User', {
    group = aug,
    pattern = { 'CodeCompanionChatDone', 'CodeCompanionChatStopped' },
    callback = function()
      codecompanion_state.is_processing = false

      -- Stop and cleanup timer
      if codecompanion_state.timer then
        codecompanion_state.timer:stop()
        codecompanion_state.timer:close()
        codecompanion_state.timer = nil
      end

      codecompanion_state.spinner_idx = 1
      vim.cmd('redrawstatus')
    end,
  })
end

-- Initialize autocmds
setup_codecompanion_autocmds()

M.CodeCompanion = {
  CodeCompanionMode,
  CodeCompanionAdapter,
  CodeCompanionModel,
  CodeCompanionSpinner,
}

return M
