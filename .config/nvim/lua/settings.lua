vim.opt.compatible = false
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.mouse = 'a'
vim.opt.autoindent = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.scrolloff = 4
vim.opt.signcolumn='yes:2'
vim.opt.hidden = true
vim.opt.number = true
vim.opt.undodir = vim.env.HOME .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.clipboard ='unnamedplus'
vim.opt.wildmenu = true
vim.opt.wrap = false
vim.opt.autochdir = false
vim.opt.diffopt ='vertical'
vim.opt.cmdheight = 2
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.termguicolors = true
vim.opt.syntax = 'on'
vim.opt.modeline = false

-- required for nvim-compe
vim.o.completeopt = 'menuone,noselect'

-- setting to 0 makes it default to value of tabstop
vim.opt.shiftwidth = 0
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wildignore:append({'*.DS_Store'})
-- enable line-wrapping with left and right cursor movement
vim.opt.whichwrap:append({['<'] = true, ['>'] = true, ['h'] = true, ['l'] = true, ['['] = true, [']'] = true})
-- add @, -, and $ as keywords for full SCSS support
vim.opt.iskeyword:append({'@-@', '-', '$'})
