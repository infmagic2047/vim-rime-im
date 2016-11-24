if get(g:, 'loaded_rime_im', 0)
    finish
endif
let g:loaded_rime_im = 1

inoremap <silent> <unique> <expr> <Plug>(rime-im-enable) rime_im#enable()
inoremap <silent> <unique> <expr> <Plug>(rime-im-disable) rime_im#disable()
inoremap <silent> <unique> <expr> <Plug>(rime-im-toggle) rime_im#toggle()
nnoremap <silent> <unique> <Plug>(rime-im-enable) :<C-U>call rime_im#enable()<CR>
nnoremap <silent> <unique> <Plug>(rime-im-disable) :<C-U>call rime_im#disable()<CR>
nnoremap <silent> <unique> <Plug>(rime-im-toggle) :<C-U>call rime_im#toggle()<CR>

if get(g:, 'rime_im_create_default_mappings', 1)
    imap <C-Space> <Plug>(rime-im-toggle)
    nmap <C-Space> <Plug>(rime-im-toggle)
endif
