-- disable indentLine in markdown cause its glitchy when trying to write
-- code-fences
vim.g.indentguides_ignorelist = { 'markdown', 'json' }

-- automatically sleuth indent styles
vim.g.sleuth_automatic = 1

-- change vim-vim modifier key from alt/option to ctrl
vim.g.move_key_modifier = 'C'

vim.cmd('let $FZF_DEFAULT_COMMAND = system("echo $FZF_DEFAULT_COMMAND")')
