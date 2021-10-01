return {
  'windwp/windline.nvim',
  config = function()
    local icons = require('nvim-nonicons')
    local modeIcons = {
      ['n'] = icons.get('vim-normal-mode'),
      ['no'] = icons.get('vim-normal-mode'),
      ['nov'] = icons.get('vim-normal-mode'),
      ['noV'] = icons.get('vim-normal-mode'),
      ['no'] = icons.get('vim-normal-mode'),
      ['niI'] = icons.get('vim-normal-mode'),
      ['niR'] = icons.get('vim-normal-mode'),
      ['niV'] = icons.get('vim-normal-mode'),
      ['v'] = icons.get('vim-visual-mode'),
      ['V'] = icons.get('vim-visual-mode'),
      [''] = icons.get('vim-visual-mode'),
      ['s'] = icons.get('vim-select-mode'),
      ['S'] = icons.get('vim-select-mode'),
      [''] = icons.get('vim-select-mode'),
      ['i'] = icons.get('vim-insert-mode'),
      ['ic'] = icons.get('vim-insert-mode'),
      ['ix'] = icons.get('vim-insert-mode'),
      ['R'] = icons.get('vim-replace-mode'),
      ['Rc'] = icons.get('vim-replace-mode'),
      ['Rv'] = icons.get('vim-replace-mode'),
      ['Rx'] = icons.get('vim-replace-mode'),
      ['c'] = icons.get('vim-command-mode'),
      ['cv'] = icons.get('vim-command-mode'),
      ['ce'] = icons.get('vim-command-mode'),
      ['r'] = icons.get('vim-replace-mode'),
      ['rm'] = icons.get('vim-replace-mode'),
      ['r?'] = icons.get('vim-replace-mode'),
      ['!'] = icons.get('terminal'),
      ['t'] = icons.get('terminal'),
    }

    local function getMode()
      local mode = vim.api.nvim_get_mode().mode
      if modeIcons[mode] == nil then
        return mode
      end

      return ' ' .. modeIcons[mode] .. '  '
    end

    local function rpad(str, len, char)
      str = tostring(str)
      char = char or ' '
      return string.rep(char, len - #str) .. str
    end

    local function lpad(str, len, char)
      str = tostring(str)
      char = char or ' '
      return str .. string.rep(char, len - #str)
    end

    local function filename(buffnr)
      local name = vim.fn.bufname(buffnr)
      return ' ' .. vim.fn.fnamemodify(name, '%:p') .. ' '
    end

    local function filetypeComponent(buffnr)
      return ' ' .. vim.api.nvim_buf_get_option(buffnr, 'filetype') .. '  '
    end

    local function filetypeIcon(buffnr)
      local fileType = vim.api.nvim_buf_get_option(buffnr, 'filetype')
      return ' ' .. (icons.get(fileType) or icons.get('file')) .. ' '
    end

    local function lineCol(_, winid, _, is_floatline)
      if is_floatline then
        winid = 0
      end
      local row, col = unpack(vim.api.nvim_win_get_cursor(winid or 0))
      return string.format(' %s:%s ', rpad(row, 3), lpad(col, 2))
    end

    local function progress()
      local line_fraction = math.floor(vim.fn.line('.') / vim.fn.line('$') * 100) .. '%%'
      return ' ' .. rpad(line_fraction, 5, ' ') .. ' '
    end

    local components = {
      { getMode(), { 'black', 'ActiveBg' } },
      { '', { 'ActiveBg', 'black' } },
      { filetypeIcon, { 'ActiveBg', 'black' } },
      { filename, { 'ActiveBg', 'black' } },
      { '%=', '' },
      { filetypeIcon, { 'ActiveBg', 'black' } },
      { filetypeComponent, { 'white', 'black' } },
      { '', { 'InactiveFg', 'black' } },
      { progress, { 'ActiveBg', 'InactiveFg' } },
      { '', { 'ActiveBg', 'InactiveFg' } },
      { lineCol, { 'black', 'ActiveBg' } },
    }

    local defaultStatusLine = {
      filetypes = { 'default' },
      active = components,
      inactive = components,
    }

    require('windline').setup({
      statuslines = {
        defaultStatusLine,
      },
    })
  end,
}
