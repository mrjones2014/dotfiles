" ALE has one setting that has to be set before loading the plugin, so keep it
" up here
" source $HOME/.config/nvim/configureale.vim
" then load plugins
lua require('plugins')
"then everything else
lua require('settings')
" source $HOME/.config/nvim/configurecoc.vim
lua require('lsp-init')
lua require('configure-plugins-generic')
lua require('custom-commands')
lua require('keybinds')
lua require('custom-filetypes')
lua require('configure-nvimtree')
lua require('configure-dashboard')
lua require('configure-autopairs')
lua require('configure-lualine')
lua require('configure-tabline')

" colorscheme config has to be loaded after lualine to load dynamic lualine
" theme
lua require('configure-theme')
