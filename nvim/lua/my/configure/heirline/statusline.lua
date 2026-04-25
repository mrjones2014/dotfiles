local my_conditions = require('my.configure.heirline.conditions')
local utils = require('heirline.utils')
local sep = require('my.configure.heirline.separators')
local path = require('my.utils.path')
local clipboard = require('my.utils.clipboard')
local editor = require('my.utils.editor')
local shared = require('my.configure.heirline.shared')

local M = {}

M.NixShell = {
  provider = sep.rounded_left,
  hl = { fg = 'blue', bg = 'surface0' },
  condition = function()
    return (vim.env.IN_NIX_SHELL or '') ~= ''
  end,
  {
    provider = '   ',
    hl = { bg = 'blue', fg = 'surface0' },
  },
}

M.Mode = {
  init = function(self)
    self.mode = vim.fn.mode(0):lower()
  end,
  static = {
    mode_icons = {
      n = '',
      v = '',
      ['\22'] = '',
      ['\22s'] = '',
      s = '󱐁',
      ['\19'] = '󱐁',
      i = '',
      r = '',
      c = '',
      ['!'] = '',
      t = '',
    },
    mode_colors = {
      n = 'green',
      i = 'blue',
      v = 'yellow',
      ['\22'] = 'cyan',
      c = 'orange',
      s = 'yellow',
      ['\19'] = 'orange',
      r = 'purple',
      ['!'] = 'green',
      t = 'green',
    },
  },
  {
    provider = function(self)
      return string.format(' %s ', self.mode_icons[self.mode])
    end,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
      return { bg = self.mode_colors[mode], fg = 'black', bold = true }
    end,
  },
  {
    provider = sep.rounded_right,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
      return { fg = self.mode_colors[mode], bg = 'surface0' }
    end,
  },
}

local active_buffer_id = nil

local function file_init(self)
  local cur_buf_name = vim.api.nvim_buf_get_name(0)
  local is_file = vim.uv.fs_stat(cur_buf_name) ~= nil

  if is_file then
    active_buffer_id = vim.api.nvim_get_current_buf()
  elseif
    not (
      active_buffer_id ~= nil
      and vim.iter(vim.api.nvim_list_wins()):map(vim.api.nvim_win_get_buf):any(function(buf)
        return buf == active_buffer_id
      end)
    )
  then
    active_buffer_id = nil
  end
  self.bufnr = active_buffer_id or vim.api.nvim_get_current_buf()
  self.bufname = vim.api.nvim_buf_get_name(self.bufnr)
  self.temporary = self.bufname:find(vim.fn.stdpath('run')) ~= nil
end

M.FileInfo = {
  init = function(self)
    local cur_buf_name = vim.api.nvim_buf_get_name(0)
    local is_file = vim.uv.fs_stat(cur_buf_name) ~= nil

    if is_file then
      active_buffer_id = vim.api.nvim_get_current_buf()
    elseif
      not (
        active_buffer_id ~= nil
        and vim.iter(vim.api.nvim_list_wins()):map(vim.api.nvim_win_get_buf):any(function(buf)
          return buf == active_buffer_id
        end)
      )
    then
      active_buffer_id = nil
    end
    self.bufnr = active_buffer_id or vim.api.nvim_get_current_buf()
    self.bufname = vim.api.nvim_buf_get_name(self.bufnr)
    self.temporary = self.bufname:find(vim.fn.stdpath('run')) ~= nil
  end,
  {
    hl = { bg = 'surface0' },
    {
      condition = function(self)
        return self.temporary
      end,
      provider = ' 󰪺',
    },
  },
  shared.FileIcon('surface0', function()
    return active_buffer_id or 0
  end, function()
    return active_buffer_id ~= nil or my_conditions.should_show_filename()
  end),
  {
    hl = { bg = 'surface0' },
    provider = ' ',
    {
      condition = function()
        return active_buffer_id ~= nil or my_conditions.should_show_filename()
      end,
      provider = function(self)
        local filepath = self.bufname
        if self.temporary then
          filepath = path.filename(filepath)
        end
        return path.relative(filepath)
      end,
      on_click = {
        callback = function(self)
          clipboard.copy(path.relative(self.bufname))
          vim.notify('Relative filepath copied to clipboard')
        end,
        name = 'heirline_copy_filepath_statusline',
      },
    },
  },
}

M.IsTmpFile = {
  init = file_init,
  hl = { bg = 'surface0' },
  {
    condition = function(self)
      return self.temporary
    end,
    provider = ' 󰪺',
  },
}

M.FilePath = {
  init = file_init,
  hl = { bg = 'surface0' },
  provider = ' ',
  {
    condition = function()
      return active_buffer_id ~= nil or my_conditions.should_show_filename()
    end,
    provider = function(self)
      local filepath = self.bufname
      if self.temporary then
        filepath = path.filename(filepath)
      end
      return path.relative(filepath)
    end,
    on_click = {
      callback = function(self)
        clipboard.copy(path.relative(self.bufname))
        vim.notify('Relative filepath copied to clipboard')
      end,
      name = 'heirline_copy_filepath',
    },
  },
}

local function unsaved_count()
  return #vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(buf)
      return vim.bo[buf].ft ~= 'minifiles'
        and vim.bo[buf].ft ~= 'dap-repl'
        and vim.bo[buf].bt ~= 'acwrite'
        and vim.bo[buf].modifiable
        and vim.bo[buf].modified
        and vim.bo[buf].buflisted
    end)
    :totable()
end

M.UnsavedChanges = {
  init = function(self)
    self.unsaved_count = unsaved_count()
  end,
  {
    condition = function(self)
      return self.unsaved_count > 0
    end,
    {
      {
        provider = sep.rounded_left,
        hl = { fg = 'yellow', bg = 'surface0' },
      },
      {
        provider = function(self)
          return string.format(' %s', self.unsaved_count)
        end,
        hl = { bg = 'yellow', fg = 'black' },
      },
      {
        provider = sep.rounded_right,
        hl = { fg = 'yellow', bg = 'surface0' },
      },
    },
  },
}

---Helper to make a toggle switch component
---@param provider string|fun(self:table):string text provider
---@param check_fn fun():boolean check function to determine toggle state
---@param toggle_fn fun() toggle function to be called on click
---@return table
local function toggle_component(provider, check_fn, toggle_fn)
  local id = tostring(vim.uv.hrtime())
  return {
    provider = provider,
    hl = { bg = 'surface0' },
    {
      provider = function()
        return check_fn() and '  ' or '  '
      end,
      hl = { bg = 'surface0' },
      on_click = { callback = toggle_fn, name = 'heirline_toggle_' .. id },
    },
  }
end

M.LspFormatToggle = toggle_component('󰗈 Formatting ', function()
  return require('my.utils.lsp').has_formatter() and require('my.utils.lsp').is_formatting_enabled()
end, function()
  require('my.utils.lsp').toggle_formatting_enabled()
end)

M.SpellCheckToggle = toggle_component('󰓆 Spellcheck ', editor.spellcheck_enabled, editor.toggle_spellcheck)

M.RecordingMacro = {
  provider = function()
    local macro_reg = vim.fn.reg_recording()
    if macro_reg == '' then
      return ''
    end

    return string.format(' Recording macro: %s  ', macro_reg)
  end,
  hl = { bg = 'surface0' },
}

local Tabpage = {
  provider = function(self)
    return string.format(' 󱥟 %s ', self.tabpage)
  end,
  hl = function(self)
    if self.is_active then
      return { bg = 'cyan', fg = 'surface0' }
    else
      return { bg = 'surface1' }
    end
  end,
  on_click = {
    callback = function(self)
      vim.api.nvim_set_current_tabpage(self.tabnr)
    end,
    name = function(self)
      return 'heirline_switch_tab_' .. tostring(self.tabnr)
    end,
  },
}

M.Tabs = {
  -- only show this component if there's 2 or more tabpages
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  utils.make_tablist(Tabpage),
}

return M
