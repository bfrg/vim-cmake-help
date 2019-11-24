" ==============================================================================
" View CMake documentation inside Vim
" File:         after/ftplugin/cmake.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Nov 24, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if !has('patch-8.1.1705')
    finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

" Open CMake documentation in a browser
command! -buffer -bar -nargs=? -complete=customlist,cmakehelp#complete CMakeHelpOnline call cmakehelp#browser(<q-args>)

nnoremap <silent><buffer> <plug>(cmake-help-browser) :<c-u>call cmakehelp#browser(expand('<cword>'))<cr>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
        \ .. ' | delc CMakeHelpOnline'
        \ .. ' | nunmap <buffer> <plug>(cmake-help-browser)'

let &cpoptions = s:save_cpo
unlet s:save_cpo
