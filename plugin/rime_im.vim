inoremap <silent> <unique> <expr> <Plug>(rime-im-enable) rime_im#enable()
inoremap <silent> <unique> <expr> <Plug>(rime-im-disable) rime_im#disable()
inoremap <silent> <unique> <expr> <Plug>(rime-im-toggle) rime_im#toggle()

if get(g:, 'rime_im_create_default_mappings', 1)
    imap <C-Space> <Plug>(rime-im-toggle)
endif
