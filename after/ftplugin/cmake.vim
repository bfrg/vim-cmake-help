" ==============================================================================
" View CMake documentation inside Vim
" File:         after/ftplugin/cmake.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Apr 17, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if !has('patch-8.1.2250')
    finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

" Open CMake documentation in a preview window
command! -buffer -bar -nargs=1 -complete=customlist,cmakehelp#complete CMakeHelp call cmakehelp#preview(<q-mods>, <q-args>)

" Open CMake documentation in a popup window
command! -buffer -bar -nargs=1 -complete=customlist,cmakehelp#complete CMakeHelpPopup call cmakehelp#popup(<q-args>)

" Open CMake documentation in a browser
command! -buffer -bar -nargs=? -complete=customlist,cmakehelp#complete CMakeHelpOnline call cmakehelp#browser(<q-args>)

nnoremap <silent><buffer> <plug>(cmake-help)        :<c-u>call cmakehelp#preview('', expand('<cword>'))<cr>
nnoremap <silent><buffer> <plug>(cmake-help-popup)  :<c-u>call cmakehelp#popup(expand('<cword>'))<cr>
nnoremap <silent><buffer> <plug>(cmake-help-online) :<c-u>call cmakehelp#browser(expand('<cword>'))<cr>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
        \ .. ' | delc CMakeHelp | delc CMakeHelpPopup | delc CMakeHelpOnline'
        \ .. ' | execute "nunmap <buffer> <plug>(cmake-help)"'
        \ .. ' | execute "nunmap <buffer> <plug>(cmake-help-popup)"'
        \ .. ' | execute "nunmap <buffer> <plug>(cmake-help-online)"'

let &cpoptions = s:save_cpo
unlet s:save_cpo
