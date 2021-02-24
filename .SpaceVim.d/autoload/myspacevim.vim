function myspacevim#before() abort

endfunction

function myspacevim#after() abort
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
    " highlight redundant trailing whitespace with colorscheme's error color
    match Error /\s\+$/
    set listchars=tab:\|\ 
    set list
endfunction

