if exists("g:loaded_zelda_autoload")
    finish
endif
let g:loaded_zelda_autoload = 1

function! zelda#version()
    return '1.0.0'
endfunction
