local conditions = require('heirline.conditions')
local sep = require('my.configure.heirline.separators')

local M = {}

M.Align = { provider = '%=', hl = { bg = 'bg_statusline' } }

M.Mode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,
  static = {
    mode_icons = {
      n = '🅽',
      no = '🅽',
      nov = '🅽',
      noV = '🅽',
      ['no\22'] = '🅽',
      niI = '🅽',
      niR = '🅽',
      niV = '🅽',
      nt = '🅽',
      v = '🆅',
      vs = '🆅',
      V = '🆅',
      Vs = '🆅',
      ['\22'] = '🆅',
      ['\22s'] = '🆅',
      s = '🆂',
      S = '🆂',
      ['\19'] = '🆂',
      i = '🅸',
      ic = '🅸',
      ix = '🅸',
      R = '🆁',
      Rc = '🆁',
      Rx = '🆁',
      Rv = '🆁',
      Rvc = '🆁',
      Rvx = '🆁',
      c = '🅲',
      cv = '🅲',
      r = '🆁',
      rm = '🆁',
      ['r?'] = '🆁',
      ['!'] = '🆁',
      t = '🆃',
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
        return { fg = self.mode_colors[mode], bg = 'bg_statusline' }
      end
    end,
  },
}

M.Branch = {
  condition = conditions.is_git_repo,
  init = function(self)
    ---@diagnostic disable-next-line: undefined-field
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = (
      (self.status_dict.added ~= 0)
      or (self.status_dict.removed ~= 0)
      or (self.status_dict.changed ~= 0)
    )
  end,
  {
    provider = function(self)
      return string.format('  %s', self.status_dict.head)
    end,
    hl = { fg = 'green', bg = 'gray' },
  },
  {
    provider = sep.rounded_right,
    hl = { fg = 'gray', bg = 'bg_statusline' },
  },
}

M.FilePath = {
  init = function(self)
    self.bufname = vim.api.nvim_buf_get_name(0)
  end,
  hl = { bg = 'bg_statusline' },
  provider = ' ',
  {
    condition = function(self)
      return require('my.configure.heirline.conditions').should_show_filename(self.bufname)
    end,
    provider = function()
      return Path.relative(vim.api.nvim_buf_get_name(0))
    end,
  },
}

local function unsaved_count()
  if #vim.fn.expand('%') == 0 then
    return 0
  else
    return #vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_get_option(buf, 'modifiable') and vim.api.nvim_buf_get_option(buf, 'modified')
    end, vim.api.nvim_list_bufs())
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
        hl = { fg = 'yellow', bg = 'bg_statusline' },
      },
      {
        provider = function(self)
          return string.format(' %s Unsaved file%s', self.unsaved_count, self.unsaved_count > 1 and 's' or '')
        end,
        hl = { bg = 'yellow', fg = 'black' },
      },
      {
        provider = sep.rounded_right,
        hl = { fg = 'yellow', bg = 'bg_statusline' },
      },
    },
  },
}

M.LazyStats = {
  provider = function()
    local icon = require('lazy.core.config').options.ui.icons.plugin
    local stats = require('lazy').stats()
    local updates = require('lazy.status').has_updates()
        and string.format(' (%s updates available)', tostring(require('lazy.status').updates()):gsub(icon, ''))
      or ''
    return string.format('%s %s/%s%s ', icon, stats.loaded, stats.count, updates)
  end,
  hl = { bg = 'bg_statusline' },
}

M.OnePassword = {
  provider = sep.rounded_left,
  hl = { fg = 'blue', bg = 'bg_statusline' },
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
    hl = { fg = 'bg_statusline', bg = 'blue' },
  },
}

return M
