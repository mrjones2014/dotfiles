local conditions = require('heirline.conditions')
local sep = require('my.configure.heirline.separators')

local special_filenames = { 'mod.rs', 'lib.rs' }

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
      return require('my.configure.heirline.conditions').should_show_filename(self.bufname)
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
      return { bg = conditions.has_diagnostics() and 'surface1' or 'surface2', fg = 'base' }
    end,
  },
}

M.Diagnostics = {
  provider = ' ',
  hl = { bg = 'surface1' },
  condition = conditions.has_diagnostics,
  require('my.configure.heirline.shared').Diagnostics(true, 'surface1'),
  {
    provider = sep.rounded_right,
    hl = { fg = 'surface1', bg = 'surface2' },
  },
}

M.Navic = {
  condition = function()
    return conditions.lsp_attached() and require('nvim-navic').is_available()
  end,
  provider = function()
    return string.format(' %s', require('nvim-navic').get_location())
  end,
  hl = { bg = 'surface0' },
}

return M
