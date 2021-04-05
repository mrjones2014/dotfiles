" ALE has one setting that has to be set before loading the plugin, so keep it
" up here
source $HOME/.config/nvim/configureale.vim
" then load plugins
source $HOME/.config/nvim/loadplugins.vim
"then everything else
source $HOME/.config/nvim/vimsettings.vim
source $HOME/.config/nvim/configurecolorscheme.vim
source $HOME/.config/nvim/configurecoc.vim
source $HOME/.config/nvim/configurenerdtree.vim
source $HOME/.config/nvim/configureairline.vim
source $HOME/.config/nvim/configurepluginsgeneric.vim
source $HOME/.config/nvim/configurecustomcommands.vim
source $HOME/.config/nvim/configurekeymap.vim
source $HOME/.config/nvim/configurestartify.vim
source $HOME/.config/nvim/configurefiletypedetection.vim

lua require'configure-treesitter'
lua require'configure-telescope'

" turn this dumb shit off in case any plugins turned it on
set noautochdir
