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

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'folke/snacks.nvim',
      lazy = false,
      opts = { bufdelete = { enabled = true } },
      keys = {
        {
          'W',
          function()
            require('snacks.bufdelete').delete(0)
          end,
          desc = 'Close current buffer',
        },
      },
    },
  },
  opts = {
    preset = 'helix',
    win = { col = 0 },
    expand = 2,
    triggers = {
      { '<auto>', mode = 'nixsotc' },
      { 'f', mode = 'n' },
    },
    spec = {
      { '<ESC>', vim.cmd.noh, desc = 'Clear highlighting on <ESC> in normal mode', hidden = true },
      {
        '<C-v>',
        mode = 'i',
        function()
          vim.cmd.normal('"+p')
          -- place the cursor at the end of the pasted region
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          local lines = vim.split(vim.fn.getreg('+'), '\n')
          if #lines == 1 then
            col = col + #lines[1]
          else
            row = row + #lines - 1
            col = #lines[#lines]
          end
          vim.api.nvim_win_set_cursor(0, { row, col })
        end,
        desc = 'Paste from system clipboard in insert mode',
      },
      {
        '<leader>jk',
        function()
          require('notify').dismiss({ silent = true, pending = true })
        end,
        desc = 'Dismiss notifications',
      },
      -- allow moving the cursor through wrapped lines using j and k,
      -- note that I have line wrapping turned off but turned on only for Markdown
      { 'j', 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', expr = true, mode = { 'n', 'v' }, hidden = true },
      { 'k', 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', expr = true, mode = { 'n', 'v' }, hidden = true },
      { '<Tab>', vim.cmd.bnext, desc = 'Move to next buffer' },
      { '<S-Tab>', vim.cmd.bprevious, desc = 'Move to previous buffer' },
      {
        '<leader>s',
        require('my.utils.editor').toggle_spellcheck,
        desc = 'Toggle spellcheck',
      },
      {
        '<C-;>',
        toggle_char_at_end_of_line(';'),
        mode = { 'n', 'i' },
        desc = 'Toggle semicolon',
      },
      {
        '<C-,>',
        toggle_char_at_end_of_line(','),
        mode = { 'n', 'i' },
        desc = 'Toggle trailing comma',
      },
      {
        '<leader>L',
        function()
          vim.cmd.Lazy()
        end,
        desc = 'Show lazy.nvim menu',
      },
    },
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
