-- TODO this file can potentially go away pending https://github.com/romgrk/barbar.nvim/issues/286

local ignored_ft = {
  'nofile',
  'TelescopePrompt',
  'NvimTree',
  'quickfix',
  'qf',
  'Trouble',
  '1PasswordSidebar',
  'help',
}

-- Get the names of all current listed buffers
local function get_current_filenames()
  local listed_buffers = vim.tbl_filter(function(bufnr)
    return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr)
  end, vim.api.nvim_list_bufs())

  return vim.tbl_map(vim.api.nvim_buf_get_name, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename, shorten)
  local filenames = vim.tbl_filter(function(filename_other)
    return filename_other ~= filename
  end, get_current_filenames())

  if shorten then
    filename = vim.fn.pathshorten(filename)
    filenames = vim.tbl_map(vim.fn.pathshorten, filenames)
  end

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

local function buf_with_icon(buf)
  local icon, hl = require('nvim-web-devicons').get_icon(vim.api.nvim_buf_get_name(buf), nil, { default = true })

  return {
    id = buf,
    name = get_unique_filename(vim.api.nvim_buf_get_name(buf)),
    icon = icon,
    icon_color = hl,
    is_active = tostring(buf) == tostring(vim.api.nvim_win_get_buf(tonumber(vim.g.statusline_winid or 0))),
  }
end

local function get_buffers()
  local listed_bufs = vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.api.nvim_buf_is_loaded(buf)
  end, vim.api.nvim_list_bufs())

  return vim.tbl_map(function(buf)
    return buf_with_icon(buf)
  end, listed_bufs)
end

vim.cmd.hi('BufLineActive guifg=#abb2bf guibg=#000000 gui=bold,italic')
vim.cmd.hi('BufLineInactive guifg=#434852 guibg=#000000')
vim.cmd.hi('BufLineBg guibg=#0D0D0D')

return function()
  if
    vim.tbl_contains(
      ignored_ft,
      vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(tonumber(vim.g.statusline_winid or 0)), 'filetype')
    )
  then
    return '%#Normal#'
  end

  local bufs = get_buffers()
  local winbar = table.concat(
    vim.tbl_map(function(buf_icon)
      return string.format(
        '%%#%s#%s %%#%s#%s',
        buf_icon.icon_color,
        buf_icon.icon,
        buf_icon.is_active and 'BufLineActive' or 'BufLineInactive',
        buf_icon.name
      )
    end, bufs),
    ' │ '
  )

  return string.format('%s │%%#BufLineBg#', winbar)
end
