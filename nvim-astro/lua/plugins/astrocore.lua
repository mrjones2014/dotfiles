--- Add or remove `char` at the end of the current line, ignoring any trailing comment.
---@param char string
---@return function
local function toggle_char_at_end_of_line(char)
  return function()
    local api = vim.api
    local line = api.nvim_get_current_line()
    local commentstring = vim.api.nvim_get_option_value('commentstring', { buf = 0 }):gsub('%%s', '')
    local escaped_commentstring = commentstring:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
    local code, comment = line:match('^(.*)' .. escaped_commentstring .. '(.*)$')

    if code then
      code = code:gsub('%s*$', '') -- remove trailing spaces
      local last_char = code:sub(-1)

      if last_char == char then
        code = code:sub(1, #code - 1)
      else
        code = code .. char
      end

      line = code .. ' ' .. commentstring .. (comment or '')
    else
      line = line:gsub('%s*$', '') -- remove trailing spaces
      local last_char = line:sub(-1)

      if last_char == char then
        line = line:sub(1, #line - 1)
      else
        line = line .. char
      end
    end

    return api.nvim_set_current_line(line)
  end
end

---@type LazySpec
return {
  'AstroNvim/astrocore',
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        showtabline = 0,
        relativenumber = false,
      },
    },
    mappings = {
      n = {
        ['<Tab>'] = { vim.cmd.bnext, desc = 'Move to next buffer' },
        ['<S-Tab>'] = { vim.cmd.bprevious, desc = 'Move to previous buffer' },
        -- AstroNvim maps these to `:split` / `:vsplit`; I don't want them
        ['\\'] = false,
        ['|'] = false,
        ['<C-;>'] = { toggle_char_at_end_of_line(';'), desc = 'Toggle semicolon' },
        ['<C-,>'] = { toggle_char_at_end_of_line(','), desc = 'Toggle trailing comma' },
      },
      i = {
        ['<C-;>'] = { toggle_char_at_end_of_line(';'), desc = 'Toggle semicolon' },
        ['<C-,>'] = { toggle_char_at_end_of_line(','), desc = 'Toggle trailing comma' },
      },
    },
  },
}
