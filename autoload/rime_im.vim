" Read user configuration variables
let s:keys_to_map = get(g:, 'rime_im_keys_to_map', split('!"#$%&''()*+,-./:;<=>?@[\]^_`abcdefghijklmnopqrstuvwxyz{|}~', '\zs'))
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

function! s:show_preedit(text) abort
    " We cannot use setline() here because it breaks undo
    execute "normal! \"=a:text\<CR>P"
    let l:len = strchars(a:text, 1)
    if l:len >= 2
        execute 'normal! ' . (l:len - 1) . 'h'
    endif
endfunction

function! s:remove_preedit(text) abort
    " We cannot use setline() here because it breaks undo
    let l:len = strchars(a:text, 1)
    if l:len >= 1
        execute 'normal! ' . l:len . 'x'
    endif
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
    let l:virtualedit_store = &virtualedit
    " Ensure the menu is shown
    set completeopt+=menuone
    " Make :normal work when the cursor is one character past the end of
    " the line
    set virtualedit+=onemore
    if !exists('s:rime_cli_job')
        let s:rime_cli_job = job_start([s:rime_cli_prog])
    endif
    let l:current_char = a:initial_char
    let l:previous_preedit = ''
    while 1
        let l:response = json_decode(ch_evalraw(s:rime_cli_job, json_encode(s:keyevent_from_char(l:current_char)) . "\n"))
        if type(l:response) != v:t_none
            if type(l:response.commit) != v:t_none
                let l:commit_text = l:response.commit.text
                break
            endif
            if type(l:response.composition) == v:t_none
                " All entered characters are erased. Exit input method.
                let l:commit_text = ''
                break
            endif
            call s:remove_preedit(l:previous_preedit)
            call s:show_preedit(l:response.composition.preedit)
            let l:previous_preedit = l:response.composition.preedit
            if type(l:response.menu) != v:t_none
                call s:show_candidates(l:response.menu.candidates)
            else
                call s:hide_candidates()
            endif
            redraw
        endif
        let l:current_char = getchar()
    endwhile
    call s:remove_preedit(l:previous_preedit)
    if pumvisible()
        " Finally hide the popup menu
        call feedkeys("\<C-E>", 'n')
    endif
    let &completeopt = l:completeopt_store
    let &virtualedit = l:virtualedit_store
    return l:commit_text
endfunction

function! s:do_mapping(mode, lhs, rhs, ...) abort
    let l:args = a:0 >= 1 ? a:1 : ''
    let s:saved_mappings[bufnr('')][a:mode . a:lhs] = maparg(a:lhs, a:mode, 0, 1)
    execute a:mode . 'noremap <buffer> ' . l:args . ' ' . escape(a:lhs, '|') . ' ' . escape(a:rhs, '|')
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
                    \ escape(l:old_mapping.lhs, '|') . ' ' .
                    \ substitute(escape(l:old_mapping.rhs, '|'), '\c<SID>', '<SNR>' . l:old_mapping.sid . '_', 'g')
    else
        execute a:mode . 'unmap <buffer> ' . escape(a:lhs, '|')
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
