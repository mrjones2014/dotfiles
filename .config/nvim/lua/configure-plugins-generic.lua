local g = vim.g
-- disable indentLine in markdown cause its glitchy when trying to write
-- code-fences
g.indentguides_ignorelist = {'markdown', 'json'}

-- automatically sleuth indent styles
g.sleuth_automatic = 1

-- change vim-vim modifier key from alt/option to ctrl
g.move_key_modifier = 'C'

vim.cmd('let $FZF_DEFAULT_COMMAND = system("echo $FZF_DEFAULT_COMMAND")')
