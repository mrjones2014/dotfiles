local conditions = require('heirline.conditions')
local my_conditions = require('my.configure.heirline.conditions')
local utils = require('heirline.utils')
local sep = require('my.configure.heirline.separators')
local path = require('my.utils.path')
local clipboard = require('my.utils.clipboard')
local editor = require('my.utils.editor')

local M = {}

M.Mode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,
  static = {
    mode_icons = {
      n = '',
      no = '',
      nov = '',
      noV = '',
      ['no\22'] = '',
      niI = '',
      niR = '',
      niV = '',
      nt = '',
      v = '',
      vs = '',
      V = '',
      Vs = '',
      ['\22'] = '',
      ['\22s'] = '',
      s = '󱐁',
      S = '󱐁',
      ['\19'] = '󱐁',
      i = '',
      ic = '',
      ix = '',
      R = '',
      Rc = '',
      Rx = '',
      Rv = '',
      Rvc = '',
      Rvx = '',
      c = '',
      cv = '',
      r = '',
      rm = '',
      ['r?'] = '',
      ['!'] = '',
      t = '',
    },
    mode_colors = {
      n = 'green',
      i = 'blue',
      v = 'yellow',
      V = 'yellow',
      ['\22'] = 'cyan',
      c = 'orange',
      s = 'yellow',
      S = 'yellow',
      ['\19'] = 'orange',
      R = 'purple',
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
      if conditions.is_git_repo() or vim.fs.root(assert(vim.uv.cwd()), '.git') then
        return { fg = self.mode_colors[mode], bg = 'gray' }
      else
        return { fg = self.mode_colors[mode], bg = 'surface0' }
      end
    end,
  },
}

M.Branch = {
  init = function(self)
    local vcs = require('my.utils.vcs')
    local url = vcs.git_remote()
    if string.find(url, 'github.com') then
      self.icon = ' '
    elseif string.find(url, 'gitlab') then
      self.icon = '󰮠 '
    else
      self.icon = ' '
    end
    self.branch = vcs.jj_bookmark_or_git_branch()
  end,
  {
    condition = function(self)
      return self.branch ~= nil and self.branch ~= ''
    end,
    {
      {
        provider = function(self)
          return string.format(' %s %s', self.icon, self.branch)
        end,
        hl = { fg = 'green', bg = 'gray' },
      },
      {
        provider = sep.rounded_right,
        hl = { fg = 'gray', bg = 'surface0' },
      },
    },
  },
}

local function file_init(self)
  self.bufname = vim.api.nvim_buf_get_name(0)
  self.temporary = self.bufname:find(vim.fn.stdpath('run')) ~= nil
end

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
    condition = function(self)
      return my_conditions.should_show_filename(self.bufname)
    end,
    provider = function(self)
      local filepath = vim.api.nvim_buf_get_name(0)
      if self.temporary then
        filepath = path.filename(filepath)
      end
      return path.relative(filepath)
    end,
    on_click = {
      callback = function()
        clipboard.copy(path.relative(vim.api.nvim_buf_get_name(0)))
        vim.notify('Relative filepath copied to clipboard')
      end,
      name = 'heirline_copy_filepath',
    },
  },
}

local function unsaved_count()
  if #vim.fn.expand('%') == 0 then
    return 0
  else
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

local function toggle_component(text, check_fn, toggle_fn)
  return {
    provider = function()
      return check_fn() and '  ' or '  '
    end,
    hl = { bg = 'surface0' },
    on_click = { callback = toggle_fn, name = 'heirline_toggle_' .. text:lower():gsub('%s+', '_') },
    { provider = text, hl = { bg = 'surface0' } },
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
    return '%' .. self.tabnr .. 'T ' .. self.tabpage .. ' %T'
  end,
  hl = function(self)
    if self.is_active then
      return { bg = 'cyan', fg = 'surface0' }
    else
      return { bg = 'surface1' }
    end
  end,
}

M.Tabs = {
  -- only show this component if there's 2 or more tabpages
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  utils.make_tablist(Tabpage),
}

M.CopilotStatus = {
  condition = function()
    -- don't cause copilot to load with `require` just for statusline
    local loaded = package.loaded.copilot
    return not not loaded
  end,
  {
    provider = function()
      local auth = require('copilot.auth')
      if not auth.is_authenticated() then
        return ''
      end
      local info = require('copilot.auth').get_creds()
      if not info then
        return ''
      end
      for _, config in pairs(info) do
        if config.githubAppId == 'Iv1.b507a08c87ecfe98' then
          return string.format('  %s ', config.user)
        end
      end
    end,
    hl = { bg = 'surface0' },
  },
}

return M
