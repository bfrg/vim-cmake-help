" ==============================================================================
" View CMake documentation inside Vim
" File:         after/ftplugin/rst.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Nov 26, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

if bufname('%')[:10] !=# 'CMake Help:'
    finish
endif

let s:save_cpo = &cpoptions
set cpoptions&vim

" Unfortunately Vim resets 'buflisted' every time a buffer is edited, see
" :h 'buflisted'.
augroup cmakehelp
    autocmd! BufWinEnter <buffer> setlocal nobuflisted
augroup END

let &cpoptions = s:save_cpo
unlet s:save_cpo
