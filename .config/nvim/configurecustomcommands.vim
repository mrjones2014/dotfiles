" :Prettier => :CocCommand prettier.formatFile
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" alias :git to :Git for vim-fugitive
cnoreabbrev git Git

" :Jest => Run jest for current project
command! -nargs=0 Jest :call  CocAction('runCommand', 'jest.projectTest')
cnoreabbrev jest Jest

" :JestCurrent => Run jest for current file
command! -nargs=0 JestCurrent :call  CocAction('runCommand', 'jest.fileTest', ['%'])
cnoreabbrev jc JestCurrent

" alias :make to :Make from my custom vim-make.vim plugin
cnoreabbrev make Make
