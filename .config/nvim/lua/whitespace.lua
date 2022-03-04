-- Modified from
-- https://github.com/echasnovski/mini.nvim/blob/91969103413bb2e29e4b4d7841e68a8a65959ccd/lua/mini/trailspace.lua
local M = {}

local H = { window_matches = {} }

function H.is_buffer_normal(buf_id)
  return vim.api.nvim_buf_get_option(buf_id or 0, 'buftype') == ''
end

function M.setup()
  vim.cmd(
    [[
      augroup TrailingWhitespace
        au!
        au WinEnter,BufEnter,InsertLeave * lua require('whitespace').highlight()
        au WinLeave,BufLeave,InsertEnter * lua require('whitespace').unhighlight()
        au BufWritePre * lua require('whitespace').trim()
        au OptionSet buftype lua require('whitespace').track_normal_buffer()
      augroup END
      hi default link TrailingWhitespace Error
    ]],
    false
  )
end

function M.highlight()
  -- Highlight only in normal mode
  if vim.fn.mode() ~= 'n' then
    M.unhighlight()
    return
  end

  if not H.is_buffer_normal() then
    return
  end

  local win_id = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win_id) then
    return
  end

  -- Don't add match id on top of existing one
  if H.window_matches[win_id] ~= nil then
    return
  end

  local match_id = vim.fn.matchadd('TrailingWhitespace', [[\s\+$]])
  H.window_matches[win_id] = { id = match_id }
end

function M.unhighlight()
  -- Don't do anything if there is no valid information to act upon
  local win_id = vim.api.nvim_get_current_win()
  local win_match = H.window_matches[win_id]
  if not vim.api.nvim_win_is_valid(win_id) or win_match == nil then
    return
  end

  -- Use `pcall` because there is an error if match id is not present. It can
  -- happen if something else called `clearmatches`.
  pcall(vim.fn.matchdelete, win_match.id)
  H.window_matches[win_id] = nil
end

function M.trim()
  -- Save cursor position to later restore
  local curpos = vim.api.nvim_win_get_cursor(0)
  -- Search and replace trailing whitespace
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.api.nvim_win_set_cursor(0, curpos)
end

--- Designed to be used with |autocmd|. No need to use it directly.
function M.track_normal_buffer()
  -- This should be used with 'OptionSet' event for 'buftype' option
  -- Empty 'buftype' means "normal buffer"
  if vim.v.option_new == '' then
    M.highlight()
  else
    M.unhighlight()
  end
end

M.setup()

return M
