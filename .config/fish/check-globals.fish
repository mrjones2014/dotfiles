if ! type thefuck >/dev/null
    echo 'Install thefuck: https://github.com/nvbn/thefuck'
else
    thefuck --alias | source
end

if ! type omf >/dev/null
    echo 'Install oh-my-fish: https://github.com/oh-my-fish/oh-my-fish'
end

if ! type fisher >/dev/null
    echo 'Install fisher: https://github.com/jorgebucaran/fisher'
end

if ! type nvim >/dev/null
    echo 'Install neovim: https://github.com/neovim/neovim'
end

if ! type fzf >/dev/null
    echo 'Install fzf: https://github.com/junegunn/fzf'
end

if ! type ag >/dev/null
    echo 'Install the Silver Searcher: https://github.com/ggreer/the_silver_searcher'
end

if ! type nvm >/dev/null
    echo 'Install nvm.fish: https://github.com/jorgebucaran/nvm.fish'
end

if ! type node >/dev/null
    echo 'Install node.js via nvm'
end

if ! type yarn >/dev/null
    echo 'Install yarn: npm i -g yarn'
end

if ! type prettier >/dev/null
    echo 'Install prettier globally for vim integration: yarn global add prettier'
end

if ! type typescript-language-server >/dev/null
    echo 'Install typescript-language-server globally for vim integration: yarn global add typescript-language-server'
end

if ! type tsc >/dev/null
    echo 'Install Typescript globally for vim integration: yarn global add typescript'
end

if ! type neovim >/dev/null
    echo 'Install neovim helper globally: yarn global add neovim'
end

if ! type eslint >/dev/null
    echo 'Install eslint globally for vim integration: yarn global add eslint'
end

if ! type tslint >/dev/null
    echo 'Install tslint globally for vim integration: yarn global add tslint'
end

