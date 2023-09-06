local conditions = require('heirline.conditions')
local myconditions = require('my.configure.heirline.conditions')
local sep = require('my.configure.heirline.separators')

local M = {}

M.Align = { provider = '%=', hl = { bg = 'bg_statusline' } }

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
        return { fg = self.mode_colors[mode], bg = 'bg_statusline' }
      end
    end,
  },
}

local function git_branch()
  local status
  if vim.b.mdpreview_session then ---@diagnostic disable-line
    status = vim.b[vim.b.mdpreview_session.source_buf].gitsigns_status_dict ---@diagnostic disable-line
  else
    status = vim.b.gitsigns_status_dict ---@diagnostic disable-line
  end
  return vim.tbl_get(status or {}, 'head')
end

M.Branch = {
  condition = function()
    return git_branch() ~= nil
  end,
  {
    provider = function()
      return string.format('  %s', git_branch())
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
      local buf = 0
      local mdpreview_session = vim.b.mdpreview_session ---@diagnostic disable-line
      if mdpreview_session then
        buf = mdpreview_session.source_buf
      end
      return Path.relative(vim.api.nvim_buf_get_name(buf))
    end,
  },
}

local function unsaved_count()
  if #vim.fn.expand('%') == 0 then
    return 0
  else
    return #vim.tbl_filter(function(buf)
      return vim.bo[buf].ft ~= 'minifiles'
        and vim.bo[buf].bt ~= 'acwrite'
        and vim.bo[buf].modifiable
        and vim.bo[buf].modified
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
    return string.format('%s %s/%s ', icon, stats.loaded, stats.count)
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

M.LspFormatToggle = {
  provider = function()
    local buf = vim.b.mdpreview_session and vim.b.mdpreview_session.source_buf or 0 ---@diagnostic disable-line
    if require('my.lsp.utils').is_formatting_supported(buf) then
      return '   '
    else
      return '   '
    end
  end,
  hl = { bg = 'bg_statusline' },
  on_click = {
    callback = function()
      require('my.lsp.utils').toggle_formatting_enabled()
    end,
    name = 'heirline_LSP',
  },
  {
    provider = 'auto-format',
    hl = { bg = 'bg_statusline' },
  },
  {
    provider = function()
      local buf = vim.b.mdpreview_session and vim.b.mdpreview_session.source_buf or 0 ---@diagnostic disable-line
      local name = require('my.lsp.utils').get_formatter_name(buf)
      if name then
        return string.format(' (%s)  ', name)
      end
      return '  '
    end,
    hl = { bg = 'bg_statusline' },
  },
}

M.MarkdownPreview = {
  condition = function()
    return conditions.buffer_matches({ filetype = { 'markdown' } }) or myconditions.is_markdown_preview()
  end,
  on_click = {
    callback = function()
      if vim.b.mdpreview_session then ---@diagnostic disable-line
        require('mdpreview').stop_preview()
      else
        require('mdpreview').preview({
          opts = {
            winnr = 0,
          },
        })
      end
    end,
    name = 'heirline_MarkdownPreview',
  },
  {
    provider = sep.rounded_right,
    hl = { bg = 'green', fg = 'bg_statusline' },
  },
  {
    provider = function()
      if vim.b.mdpreview_session then ---@diagnostic disable-line
        return '   Source  '
      end
      return '   Preview  '
    end,
    hl = { bg = 'green', fg = 'bg_statusline' },
  },
  {
    provider = sep.rounded_right,
    hl = { bg = 'bg_statusline', fg = 'green' },
  },
}

return M
