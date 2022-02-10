vim.opt.compatible = false
vim.opt.cursorline = false
vim.opt.autoread = true
vim.opt.mouse = 'a'
vim.opt.autoindent = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.scrolloff = 4
vim.opt.signcolumn = 'yes:2'
vim.opt.hidden = true
vim.opt.number = true
vim.opt.undodir = vim.env.HOME .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'
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

-- setting to 0 makes it default to value of tabstop
vim.opt.shiftwidth = 0
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wildignore:append({ '*.DS_Store' })
-- enable line-wrapping with left and right cursor movement
vim.opt.whichwrap:append({ ['<'] = true, ['>'] = true, ['h'] = true, ['l'] = true, ['['] = true, [']'] = true })
-- add @, -, and $ as keywords for full SCSS support
vim.opt.iskeyword:append({ '@-@', '-', '$' })

-- netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- tree
vim.g.netrw_altv = 2
