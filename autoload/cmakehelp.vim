" ==============================================================================
" View CMake documentation inside Vim
" File:         autoload/cmakehelp.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Nov 24, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:defaults = #{
        \ exe: exepath('cmake'),
        \ browser: 'firefox'
        \ }

let s:helplists = #{
        \ command: [],
        \ manual: [],
        \ module: [],
        \ policy: [],
        \ property: [],
        \ variable: []
        \ }

" Obtain the group of a CMake keyword
" For example, s:lookup['set_target_properties'] returns 'command'
let s:lookup = {}

" CMake version, like 3.15
let s:version = ''

" Check order: b:cmakehelp -> g:cmakehelp -> s:defaults
let s:get = {k -> get(get(b:, 'cmakehelp', get(g:, 'cmakehelp', {})), k, s:defaults[k])}

function! s:error(...) abort
    echohl ErrorMsg | echomsg call('printf', a:000) | echohl None
    return 0
endfunction

" Obtain CMake version from 'cmake --version'
function! s:init_cmake_version() abort
    let output = systemlist(s:get('exe') .. ' --version')[0]
    if v:shell_error
        return s:error('cmake-help: couldn''t determine CMake version')
    endif
    let s:version = matchstr(output, '\c^\s*cmake\s\+version\s\+\zs\d\.\d\+\ze.*$')
endfunction

" Initialize lookup-table for finding the group (command, property, variable) of
" a CMake keyword
function! s:init_helplists() abort
    for i in keys(s:helplists)
        silent let s:helplists[i] = systemlist(printf('%s --help-%s-list', s:get('exe'), i))
        for k in s:helplists[i]
            let s:lookup[k] = i
        endfor
    endfor
endfunction

" Open CMake documentation for 'word' in a browser
function! cmakehelp#browser(word) abort
    if empty(s:version)
        call s:init_cmake_version()
    endif

    if empty(a:word)
        let url = 'https://cmake.org/cmake/help/v' .. s:version
    else
        let group = get(s:lookup, a:word, get(s:lookup, tolower(a:word), ''))

        if empty(group)
            return s:error('cmake-help: not a valid CMake keyword "%s"', a:word)
        endif

        if group ==# 'manual'
            let word = substitute(a:word[:-2], '(', '.', '')
        else
            let word = substitute(a:word, '<\|>', '', 'g')
        endif

        let url = printf('https://cmake.org/cmake/help/v%s/%s/%s.html',
                \ s:version,
                \ group,
                \ word
                \ )

        if group ==# 'property'
            let url = printf('https://cmake.org/cmake/help/v%s/manual/cmake-properties.7.html',
                    \ s:version
                    \ )
        endif
    endif

    let cmd = printf('exec %s %s &', s:get('browser'), url)
    return job_start([&shell, &shellcmdflag, cmd], #{
            \ in_io: 'null',
            \ out_io: 'null',
            \ err_io: 'null'
            \ })
endfunction

function! cmakehelp#complete(arglead, cmdline, cursorpos) abort
    return keys(s:lookup)->filter({_,i -> match(i, a:arglead) == 0})->sort()
endfunction

call s:init_helplists()

let &cpoptions = s:save_cpo
unlet s:save_cpo
