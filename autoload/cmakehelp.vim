" ==============================================================================
" View CMake documentation inside Vim
" File:         autoload/cmakehelp.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Nov 26, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

hi def link CMakeHelp           Pmenu
hi def link CMakeHelpTitle      Pmenu
hi def link CMakeHelpScrollbar  PmenuSbar
hi def link CMakeHelpThumb      PmenuThumb

let s:defaults = #{
        \ exe: 'cmake',
        \ browser: 'firefox',
        \ minwidth: 60,
        \ maxwidth: 90,
        \ minheight: 5,
        \ maxheight: 30,
        \ title: v:false,
        \ close: 'none',
        \ scrollup: "\<s-pageup>",
        \ scrolldown: "\<s-pagedown>",
        \ top: "\<s-home>",
        \ bottom: "\<s-end>",
        \ scrollbar: v:true
        \ }

let s:helplists = #{
        \ command: [],
        \ manual: [],
        \ module: [],
        \ policy: [],
        \ property: [],
        \ variable: []
        \ }

" Lookup table, example: s:lookup['set_target_properties'] -> 'command'
let s:lookup = {}

" CMake version, like v3.15, or 'latest'
let s:version = ''

" Last word the cursor was on; required for balloonevalexpr
let s:lastword = ''

" winid of current popup window
let s:winid = 0

" Check order: b:cmakehelp -> g:cmakehelp -> s:defaults
let s:get = {k -> get(get(b:, 'cmakehelp', get(g:, 'cmakehelp', {})), k, get(s:defaults, k))}

" Get the group of a CMake keyword
let s:getgroup = {word -> get(s:lookup, word, get(s:lookup, tolower(word), ''))}

" Get the name of a CMake help buffer
let s:bufname = {group, word -> printf('CMake Help: %s [%s]', word, group)}

function! s:error(...) abort
    echohl ErrorMsg | echomsg call('printf', a:000) | echohl None
    return 0
endfunction

" Obtain CMake version from 'cmake --version'
function! s:init_cmake_version() abort
    let output = systemlist(s:get('exe') .. ' --version')[0]
    if v:shell_error
        let s:version = 'latest'
        return
    endif
    let s:version = 'v' .. matchstr(output, '\c^\s*cmake\s\+version\s\+\zs\d\.\d\+\ze.*$')
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

" Return new rst buffer
function! s:bufnew(bufname) abort
    let bufnr = bufadd(a:bufname)
    silent call bufload(bufnr)
    call setbufvar(bufnr, '&swapfile', 0)
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&filetype', 'rst')
    return bufnr
endfunction

" TODO allow empty word for running 'cmake --help-full'
function! s:help_buffer(word) abort
    if empty(a:word)
        return
    endif

    let group = s:getgroup(a:word)
    if empty(group)
        return s:error('cmake-help: not a valid CMake keyword "%s"', a:word)
    endif

    let bufname = s:bufname(group, a:word)

    " Note: when CTRL-O is pressed, Vim automatically adds old 'CMake Help'
    " buffers to the buffer list, see :ls!, which will be unloaded and empty
    if !bufexists(bufname) || (bufexists(bufname) && !bufloaded(bufname))
        let cmd = printf('%s --help-%s %s', s:get('exe'), group, shellescape(a:word))
        silent let output = systemlist(cmd)

        if empty(output)
            return s:error('cmake-help: no output from running "%s"', cmd)
        endif

        if v:shell_error
            return s:error('cmake-help: error running "%s"', cmd)
        endif

        let bufnr = s:bufnew(bufname)
        call setbufline(bufnr, 1, output)
        call setbufvar(bufnr, '&modifiable', 0)
        call setbufvar(bufnr, '&readonly', 1)
        return bufnr
    endif

    return bufnr(bufname)
endfunction

function! s:popup_opts(bufnr) abort
    let opts = #{
            \ minwidth: s:get('minwidth'),
            \ maxwidth: s:get('maxwidth'),
            \ minheight: s:get('minheight'),
            \ maxheight: s:get('maxheight'),
            \ firstline: 1,
            \ highlight: 'CMakeHelp',
            \ padding: [0,1,1,1],
            \ border: [1,0,0,0],
            \ borderchars: [' '],
            \ drag: v:true,
            \ borderhighlight: ['CMakeHelpTitle'],
            \ close: s:get('close'),
            \ mapping: v:false,
            \ scrollbar: s:get('scrollbar'),
            \ scrollbarhighlight: 'CMakeHelpScrollbar',
            \ scrollbarthumb: 'CMakeHelpThumb',
            \ filter: funcref('s:popup_filter')
            \ }

    if s:get('title')
        call extend(opts, #{title: bufname(a:bufnr)})
    endif

    return opts
endfunction

function! s:popup_filter(winid, key) abort
    if a:key ==# s:get('scrollup')
        let line = popup_getoptions(a:winid).firstline
        let newline = (line - 2) > 0 ? (line - 2) : 1
        call popup_setoptions(a:winid, #{firstline: newline})
        return v:true
    elseif a:key ==# s:get('scrolldown')
        let line = popup_getoptions(a:winid).firstline
        " TODO use line('$', winid) in the future, requires 8.1.1967
        call win_execute(a:winid, 'let g:nlines = line("$")')
        let newline = line < g:nlines ? (line + 2) : g:nlines
        call popup_setoptions(a:winid, #{firstline: newline})
        unlet g:nlines
        return v:true
    elseif a:key ==# s:get('top')
        call popup_setoptions(a:winid, #{firstline: 1})
        return v:true
    elseif a:key ==# s:get('bottom')
        let height = popup_getpos(a:winid).core_height
        call win_execute(a:winid, 'let g:nlines = line("$")')
        let newline = g:nlines >= height ? (g:nlines - height + 1) : 1
        call popup_setoptions(a:winid, #{firstline: newline})
        unlet g:nlines
        return v:true
    endif
    return v:false
endfunction

function! s:balloon_popup(word, tid) abort
    let bufnr = s:help_buffer(a:word)
    if !bufnr
        return
    endif
    let s:winid = popup_beval(bufnr, s:popup_opts(bufnr))
endfunction

" Open CMake documentation for 'word' in the preview window
function! cmakehelp#preview(mods, word) abort
    let bufnr = s:help_buffer(a:word)
    if !bufnr || bufwinnr(bufname(bufnr)) > 0
        return
    endif
    silent execute a:mods 'pedit' fnameescape(bufname(bufnr))
endfunction

" Open CMake documentation for 'word' in popup window at current cursor position
function! cmakehelp#popup(word) abort
    let bufnr = s:help_buffer(a:word)
    if !bufnr
        return
    endif
    let s:winid = popup_atcursor(bufnr, s:popup_opts(bufnr))
endfunction

" Open CMake documentation for 'word' in a browser
function! cmakehelp#browser(word) abort
    if empty(s:version)
        call s:init_cmake_version()
    endif

    if empty(a:word)
        let url = 'https://cmake.org/cmake/help/' .. s:version
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

        let url = printf('https://cmake.org/cmake/help/%s/%s/%s.html',
                \ s:version,
                \ group,
                \ word
                \ )

        if group ==# 'property'
            let url = printf('https://cmake.org/cmake/help/%s/manual/cmake-properties.7.html',
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

function! cmakehelp#balloonexpr() abort
    if s:winid && !empty(popup_getpos(s:winid))
        if s:lastword == v:beval_text
            return ''
        endif
        call popup_close(s:winid)
        let s:winid = 0
    endif

    let s:lastword = v:beval_text
    " We need a timer, or else: E523 Not allowed here
    " Buffer can't be modified inside balloonexpr
    call timer_start(1, funcref('s:balloon_popup', [v:beval_text]))
    return ''
endfunction

function! cmakehelp#complete(arglead, cmdline, cursorpos) abort
    return keys(s:lookup)->filter({_,i -> match(i, a:arglead) == 0})->sort()
endfunction

call s:init_helplists()

let &cpoptions = s:save_cpo
unlet s:save_cpo
