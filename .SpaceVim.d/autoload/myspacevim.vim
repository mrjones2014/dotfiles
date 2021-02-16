function myspacevim#before() abort

endfunction

function myspacevim#after() abort
    let $FZF_DEFAULT_COMMAND ='ag --hidden --ignore .git -g ""'
endfunction

