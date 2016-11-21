" Read user configuration variables
let s:keys_to_map = get(g:, 'rime_im_keys_to_map', split('abcdefghijklmnopqrstuvwxyz,.\', '\zs'))
let s:rime_cli_prog = get(g:, 'rime_im_rime_cli_prog', 'rime-cli')

let s:saved_mappings = {}

function! s:keyevent_from_char(char) abort
    " TODO: handle more keys
    if type(a:char) == v:t_number
        if a:char >= 0x20 && a:char <= 0x7e
            return {'keycode': a:char, 'modifiers': 0}
        endif
    else
        if a:char ==# "\<BS>"
            return {'keycode': 0xff08, 'modifiers': 0}
        endif
    endif
    " Unknown key
    return {'keycode': 0, 'modifiers': 0}
endfunction

function! s:format_candidate(candidate) abort
    let l:label_str = type(a:candidate.label) == v:t_none ? '' : a:candidate.label . ': '
    let l:comment_str = type(a:candidate.comment) == v:t_none ? '' : ' ' . a:candidate.comment
    return l:label_str . a:candidate.text . l:comment_str
endfunction

function! s:show_candidates(candidates) abort
    let l:items = []
    for l:c in a:candidates
        call add(l:items, {'word': '', 'dup': 1, 'empty': 1,
                    \ 'abbr': s:format_candidate(l:c)})
    endfor
    call complete(col('.'), l:items)
endfunction

function! s:hide_candidates() abort
    call complete(col('.'), [{'word': '', 'empty': 1}])
endfunction

function! s:start_im(initial_char) abort
    let l:completeopt_store = &completeopt
    set completeopt+=menuone
    let l:line_content_orig = getline('.')
    if !exists('s:rime_cli_job')
        let s:rime_cli_job = job_start([s:rime_cli_prog])
    endif
    let l:current_char = a:initial_char
    while 1
        let l:response = json_decode(ch_evalraw(s:rime_cli_job, json_encode(s:keyevent_from_char(l:current_char)) . "\n"))
        if type(l:response) != v:t_none
            if type(l:response.commit) != v:t_none
                let l:commit_text = l:response.commit.text
                break
            endif
            if type(l:response.composition) != v:t_none
                call setline('.', l:line_content_orig . l:response.composition.preedit)
            else
                call setline('.', l:line_content_orig)
            endif
            if type(l:response.menu) != v:t_none
                call s:show_candidates(l:response.menu.candidates)
            else
                call s:hide_candidates()
            endif
            redraw
        endif
        let l:current_char = getchar()
    endwhile
    call setline('.', l:line_content_orig)
    let &completeopt = l:completeopt_store
    return l:commit_text
endfunction

function! s:do_mapping(mode, lhs, rhs, ...) abort
    let l:args = a:0 >= 1 ? a:1 : ''
    let s:saved_mappings[bufnr('')][a:mode . a:lhs] = maparg(a:lhs, a:mode, 0, 1)
    execute a:mode . 'noremap <buffer> ' . l:args . ' ' . a:lhs . ' ' . a:rhs
endfunction

function! s:restore_mapping(mode, lhs) abort
    let l:old_mapping = s:saved_mappings[bufnr('')][a:mode . a:lhs]
    if get(l:old_mapping, 'buffer')
        execute (l:old_mapping.mode !=# ' ' && l:old_mapping.mode !=# '!' ? l:old_mapping.mode : '') .
                    \ (l:old_mapping.noremap ? 'noremap' : 'map') .
                    \ (l:old_mapping.mode ==# '!' ? '!' : '') .
                    \ (l:old_mapping.buffer ? ' <buffer>' : '') .
                    \ (l:old_mapping.nowait ? ' <nowait>' : '') .
                    \ (l:old_mapping.silent ? ' <silent>' : '') .
                    \ (l:old_mapping.expr ? ' <expr>' : '') .
                    \ l:old_mapping.lhs . ' ' .
                    \ substitute(l:old_mapping.rhs, '\c<SID>', '<SNR>' . l:old_mapping.sid . '_', 'g')
    else
        execute a:mode . 'unmap <buffer> ' . a:lhs
    endif
    unlet s:saved_mappings[bufnr('')][a:mode . a:lhs]
endfunction

function! s:enable() abort
    if !executable(s:rime_cli_prog) || exists('s:saved_mappings[bufnr('''')]')
        return
    endif
    let s:saved_mappings[bufnr('')] = {}
    for l:ch in s:keys_to_map
        call s:do_mapping('i', l:ch, '<C-R>=<SID>start_im(' . char2nr(l:ch) . ')<CR>', '<silent> <nowait>')
    endfor
endfunction

function! s:disable() abort
    if !exists('s:saved_mappings[bufnr('''')]')
        return
    endif
    for l:ch in s:keys_to_map
        call s:restore_mapping('i', l:ch)
    endfor
    unlet s:saved_mappings[bufnr('')]
endfunction

function! rime_im#enable() abort
    call s:enable()
    return ''
endfunction

function! rime_im#disable() abort
    call s:disable()
    return ''
endfunction

function! rime_im#toggle() abort
    if !exists('s:saved_mappings[bufnr('''')]')
        call s:enable()
    else
        call s:disable()
    endif
    return ''
endfunction
