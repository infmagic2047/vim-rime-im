function! rime_im#keysym#keyevent_from_char(char) abort
    " TODO: handle more keys
    if type(a:char) == v:t_number
        if a:char >= 0x20 && a:char <= 0x7e
            return {'keysym': a:char, 'modifiers': 0}
        endif
    else
        if a:char ==# "\<BS>"
            return {'keysym': 0xff08, 'modifiers': 0}
        endif
    endif
    " Unknown key
    return {'keysym': 0, 'modifiers': 0}
endfunction
