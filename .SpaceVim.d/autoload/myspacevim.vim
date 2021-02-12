function myspacevim#before() abort

endfunction

function myspacevim#after() abort
    let g:tokyonight_style = "night"
    let g:tokyonight_enable_italic = 1
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
endfunction

