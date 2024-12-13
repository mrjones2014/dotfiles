local conditions = require('heirline.conditions')
local sep = require('my.configure.heirline.separators')
local path = require('my.utils.path')
local clipboard = require('my.utils.clipboard')
local editor = require('my.utils.editor')

local M = {}

M.Align = { provider = '%=', hl = { bg = 'surface0' } }

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
      if conditions.is_git_repo() then
        return { fg = self.mode_colors[mode], bg = 'gray' }
      else
        return { fg = self.mode_colors[mode], bg = 'surface0' }
      end
    end,
  },
}

local function git_branch()
  return vim.tbl_get(vim.b.gitsigns_status_dict or {}, 'head')
end

M.Branch = {
  condition = function()
    return git_branch() ~= nil
  end,
  on_click = {
    callback = function()
      local branch = git_branch()
      if branch and branch ~= '' then
        clipboard.copy(branch)
        vim.notify('Git branch copied to clipboard')
      end
    end,
    name = 'heirline_copy_git_branch',
  },
  {
    provider = function()
      return string.format('  %s', git_branch())
    end,
    hl = { fg = 'green', bg = 'gray' },
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'gray', bg = 'surface0' },
  },
}

M.FilePath = {
  init = function(self)
    self.bufname = vim.api.nvim_buf_get_name(0)
  end,
  hl = { bg = 'surface0' },
  provider = ' ',
  {
    condition = function(self)
      return require('my.configure.heirline.conditions').should_show_filename(self.bufname)
    end,
    provider = function()
      return path.relative(vim.api.nvim_buf_get_name(0))
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
          return string.format(' %s Unsaved file%s', self.unsaved_count, self.unsaved_count > 1 and 's' or '')
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

M.LazyStats = {
  provider = function()
    local icon = require('lazy.core.config').options.ui.icons.plugin
    local stats = require('lazy').stats()
    return string.format('%s %s/%s ', icon, stats.loaded, stats.count)
  end,
  hl = { bg = 'surface0' },
}

M.OnePassword = {
  provider = sep.rounded_left,
  hl = { fg = 'blue', bg = 'surface0' },
  {
    provider = function()
      if not vim.g.op_nvim_remote_loaded then
        return ' 1P: Signed Out'
      end

      return require('op.statusline').component()
    end,
    hl = { bg = 'blue', fg = 'black' },
  },
  {
    provider = string.format(' %s', sep.rounded_left),
    hl = { fg = 'surface0', bg = 'blue' },
  },
}

M.LspFormatToggle = {
  provider = function()
    if require('my.utils.lsp').is_formatting_supported(0) then
      return '   '
    else
      return '   '
    end
  end,
  hl = { bg = 'surface0' },
  on_click = {
    callback = function()
      require('my.utils.lsp').toggle_formatting_enabled()
    end,
    name = 'heirline_LSP',
  },
  {
    provider = '󰗈  auto-format',
    hl = { bg = 'surface0' },
  },
  {
    provider = function()
      local name = require('my.utils.lsp').get_formatter_name(0)
      if name then
        return string.format(' (%s)  ', name)
      end
      return '  '
    end,
    hl = { bg = 'surface0' },
  },
}

M.SpellCheckToggle = {
  provider = function()
    if editor.spellcheck_enabled() then
      return '   '
    else
      return '   '
    end
  end,
  hl = { bg = 'surface0' },
  on_click = {
    callback = editor.toggle_spellcheck,
    name = 'heirline_Spellcheck',
  },
  {
    provider = '󰓆  Spellcheck  ',
    hl = { bg = 'surface0' },
  },
}

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

return M
