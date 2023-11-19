local conditions = require('heirline.conditions')
local sep = require('my.configure.heirline.separators')

local function get_current_filenames()
  local listed_buffers = vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr)
  end, vim.api.nvim_list_bufs())

  return vim.tbl_map(vim.api.nvim_buf_get_name, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename)
  local filenames = vim.tbl_filter(function(filename_other)
    return filename_other ~= filename
  end, get_current_filenames())

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  filenames = vim.tbl_map(string.reverse, filenames)

  local index

  -- For every other filename, compare it with the name of the current file char-by-char to
  -- find the minimum index `i` where the i-th character is different for the two filenames
  -- After doing it for every filename, get the maximum value of `i`
  if next(filenames) then
    index = math.max(unpack(vim.tbl_map(function(filename_other)
      for i = 1, #filename do
        -- Compare i-th character of both names until they aren't equal
        if filename:sub(i, i) ~= filename_other:sub(i, i) then
          return i
        end
      end
      return 1
    end, filenames)))
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

  return string.reverse(string.sub(filename, 1, index))
end

local M = {}

M.UniqueFilename = {
  init = function(self)
    self.bufname = get_unique_filename(vim.api.nvim_buf_get_name(0))
  end,
  {
    condition = function(self)
      return require('my.configure.heirline.conditions').should_show_filename(self.bufname)
    end,
    provider = function(self)
      return string.format(' %s ', self.bufname)
    end,
    hl = { bg = 'black' },
  },
  {
    -- file save status indicator
    condition = function()
      return vim.bo.modified == true
    end,
    provider = ' ',
    hl = { bg = 'black' },
  },
  {
    provider = sep.rounded_right,
    hl = function()
      if conditions.has_diagnostics() then
        return { bg = 'gray', fg = 'black' }
      else
        return { bg = 'bg_statusline', fg = 'black' }
      end
    end,
  },
}

M.Diagnostics = {
  provider = ' ',
  hl = { bg = 'gray' },
  condition = conditions.has_diagnostics,
  require('my.configure.heirline.shared').Diagnostics(true, 'gray'),
  {
    provider = sep.rounded_right,
    hl = { fg = 'gray', bg = 'bg_statusline' },
  },
}

M.Navic = {
  condition = function()
    return conditions.lsp_attached() and require('nvim-navic').is_available()
  end,
  provider = function()
    return string.format(' %s', require('nvim-navic').get_location())
  end,
  hl = { bg = 'bg_statusline' },
}

return M
