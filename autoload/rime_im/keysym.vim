let s:special_keys = {
            \ "\<BS>": {'keysym': 0xff08, 'modifiers': 0},
            \ "\<F1>": {'keysym': 0xffbe, 'modifiers': 0},
            \ "\<F2>": {'keysym': 0xffbf, 'modifiers': 0},
            \ "\<F3>": {'keysym': 0xffc0, 'modifiers': 0},
            \ "\<F4>": {'keysym': 0xffc1, 'modifiers': 0},
            \ "\<F5>": {'keysym': 0xffc2, 'modifiers': 0},
            \ "\<F6>": {'keysym': 0xffc3, 'modifiers': 0},
            \ "\<F7>": {'keysym': 0xffc4, 'modifiers': 0},
            \ "\<F8>": {'keysym': 0xffc5, 'modifiers': 0},
            \ "\<F9>": {'keysym': 0xffc6, 'modifiers': 0},
            \ "\<F10>": {'keysym': 0xffc7, 'modifiers': 0},
            \ "\<F11>": {'keysym': 0xffc8, 'modifiers': 0},
            \ "\<F12>": {'keysym': 0xffc9, 'modifiers': 0},
            \ "\<F13>": {'keysym': 0xffca, 'modifiers': 0},
            \ "\<F14>": {'keysym': 0xffcb, 'modifiers': 0},
            \ "\<F15>": {'keysym': 0xffcc, 'modifiers': 0},
            \ "\<F16>": {'keysym': 0xffcd, 'modifiers': 0},
            \ "\<F17>": {'keysym': 0xffce, 'modifiers': 0},
            \ "\<F18>": {'keysym': 0xffcf, 'modifiers': 0},
            \ "\<F19>": {'keysym': 0xffd0, 'modifiers': 0},
            \ "\<F20>": {'keysym': 0xffd1, 'modifiers': 0},
            \ "\<F21>": {'keysym': 0xffd2, 'modifiers': 0},
            \ "\<F22>": {'keysym': 0xffd3, 'modifiers': 0},
            \ "\<F23>": {'keysym': 0xffd4, 'modifiers': 0},
            \ "\<F24>": {'keysym': 0xffd5, 'modifiers': 0},
            \ "\<F25>": {'keysym': 0xffd6, 'modifiers': 0},
            \ "\<F26>": {'keysym': 0xffd7, 'modifiers': 0},
            \ "\<F27>": {'keysym': 0xffd8, 'modifiers': 0},
            \ "\<F28>": {'keysym': 0xffd9, 'modifiers': 0},
            \ "\<F29>": {'keysym': 0xffda, 'modifiers': 0},
            \ "\<F30>": {'keysym': 0xffdb, 'modifiers': 0},
            \ "\<F31>": {'keysym': 0xffdc, 'modifiers': 0},
            \ "\<F32>": {'keysym': 0xffdd, 'modifiers': 0},
            \ "\<F33>": {'keysym': 0xffde, 'modifiers': 0},
            \ "\<F34>": {'keysym': 0xffdf, 'modifiers': 0},
            \ "\<F35>": {'keysym': 0xffe0, 'modifiers': 0},
            \ }

function! rime_im#keysym#keyevent_from_char(char) abort
    " TODO: handle more keys
    if type(a:char) == v:t_number
        if a:char >= 0x20 && a:char <= 0x7e
            return {'keysym': a:char, 'modifiers': 0}
        endif
    else
        if exists('s:special_keys[a:char]')
            return s:special_keys[a:char]
        endif
    endif
    " Unknown key
    return {'keysym': 0, 'modifiers': 0}
endfunction
