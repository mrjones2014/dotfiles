vim.g.mapleader = ' '
vim.opt.compatible = false
vim.opt.cursorline = false
vim.opt.autoread = true
vim.opt.mouse = 'a'
vim.opt.autoindent = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.scrolloff = 4
vim.opt.signcolumn = 'yes:3'
vim.opt.hidden = true
vim.opt.number = true
vim.opt.undodir = string.format('%s/undo', vim.fn.stdpath('data'))
vim.opt.undofile = true
vim.opt.wildmenu = true
vim.opt.wrap = false
vim.opt.autochdir = false
vim.opt.diffopt = 'vertical'
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.termguicolors = true
vim.opt.syntax = 'on'
vim.opt.modeline = true
vim.opt.updatetime = 100
vim.opt.confirm = true
vim.opt.showtabline = 0
vim.opt.cmdheight = 0
vim.opt.sessionoptions = 'buffers,curdir,folds,winpos,winsize,localoptions'
vim.opt.laststatus = 3
vim.opt.virtualedit = 'onemore'
vim.opt.splitkeep = 'screen'
vim.opt.clipboard = 'unnamedplus'
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  -- TODO for some reason, you have to hit ctrl+c after
  -- pasting for the text to actually appear, but it still works.
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

-- setting to 0 makes it default to value of tabstop
vim.opt.shiftwidth = 0
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.shortmess:append('I')
vim.opt.wildignore:append({ '*.DS_Store' })
-- enable line-wrapping with left and right cursor movement
vim.opt.whichwrap:append({ ['<'] = true, ['>'] = true, ['h'] = true, ['l'] = true, ['['] = true, [']'] = true })
-- add @, -, and $ as keywords for full SCSS support
vim.opt.iskeyword:append({ '@-@', '-', '$' })
-- slightly thicker window separators
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft = '┫',
  vertright = '┣',
  verthoriz = '╋',
  eob = ' ',
}

vim.filetype.add({
  pattern = {
    ['*.jsonc'] = 'jsonc',
    ['tsconfig.json'] = 'jsonc',
    ['tsconfig*.json'] = 'jsonc',
  },
})
