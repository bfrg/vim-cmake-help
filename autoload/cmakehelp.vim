" ==============================================================================
" View CMake documentation inside Vim
" File:         autoload/cmakehelp.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-cmake-help
" Last Change:  Aug 23, 2020
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

hi def link CMakeHelp           Pmenu
hi def link CMakeHelpScrollbar  PmenuSbar
hi def link CMakeHelpThumb      PmenuThumb

const s:defaults = {
        \ 'exe': 'cmake',
        \ 'browser': 'firefox',
        \ 'scrollup': "\<s-pageup>",
        \ 'scrolldown': "\<s-pagedown>",
        \ 'top': "\<s-home>",
        \ 'bottom': "\<s-end>",
        \ 'maxheight': 0
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
const s:get = {k -> get(b:, 'cmakehelp', get(g:, 'cmakehelp', {}))->get(k, s:defaults[k])}

" Get the group of a CMake keyword
const s:getgroup = {word -> get(s:lookup, word, get(s:lookup, tolower(word), ''))}

" Get the name of a CMake help buffer
const s:bufname = {group, word -> printf('CMake Help: %s [%s]', word, group)}

" Stop any running jobs
const s:job_stop = {-> exists('s:job') && job_status(s:job) ==# 'run' ? job_stop(s:job) : {-> 0}}

function s:error(...)
    echohl ErrorMsg | echomsg call('printf', a:000) | echohl None
endfunction

" Obtain CMake version from 'cmake --version'
function s:init_cmake_version() abort
    const output = systemlist(s:get('exe') .. ' --version')[0]
    if v:shell_error
        let s:version = 'latest'
        return
    endif
    let s:version = 'v' .. matchstr(output, '\c^\s*cmake\s\+version\s\+\zs\d\.\d\+\ze.*$')
endfunction

" Initialize lookup-table for finding the group (command, property, variable) of
" a CMake keyword
function s:init_lookup() abort
    const groups = ['command', 'manual', 'module', 'policy', 'property', 'variable']
    for i in groups
        silent let words = systemlist(printf('%s --help-%s-list', s:get('exe'), i))
        for k in words
            let s:lookup[k] = i
        endfor
    endfor
endfunction

" 'callback' is called after the channel is closed and its output has been read.
" The output will be appended to a prepared buffer. 'callback' is called with
" one argument, the buffer number of the prepared buffer and is supposed to open
" a window with the passed buffer (popup window or normal window)
function s:openhelp(word, callback) abort
    if empty(a:word)
        return
    endif

    const group = s:getgroup(a:word)
    if empty(group)
        redraw
        return s:error('cmake-help: not a valid CMake keyword "%s"', a:word)
    endif

    const bufname = s:bufname(group, a:word)

    " Note: when CTRL-O is pressed, Vim automatically adds old 'CMake Help'
    " buffers to the buffer list, see :ls!, which will be unloaded and empty
    if !bufexists(bufname) || (bufexists(bufname) && !bufloaded(bufname))
        call s:job_stop()
        let cmd = printf('%s --help-%s %s', s:get('exe'), group, shellescape(a:word))
        let s:job = job_start([&shell, &shellcmdflag, cmd], {
                \ 'out_mode': 'raw',
                \ 'in_io': 'null',
                \ 'err_cb': {_,msg -> s:error('cmake-help: %s', msg)},
                \ 'close_cb': funcref('s:close_cb', [a:callback, bufname])
                \ })
        return
    endif

    " Buffer already exists with content, we don't have to call CMake again
    call a:callback(bufnr(bufname))
endfunction

function s:close_cb(callback, bufname, channel) abort
    let output = []
    while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
        call extend(output, split(ch_readraw(a:channel), "\n"))
    endwhile

    if empty(output)
        return s:error('cmake-help: no output from running "%s"', cmd)
    endif

    const bufnr = bufadd(a:bufname)
    silent call bufload(bufnr)
    call setbufvar(bufnr, '&swapfile', 0)
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&filetype', 'rst')
    call setbufline(bufnr, 1, output)
    call setbufvar(bufnr, '&modifiable', 0)
    call setbufvar(bufnr, '&readonly', 1)
    call a:callback(bufnr)
endfunction

function s:popup_filter(winid, key) abort
    if line('$', a:winid) == popup_getpos(a:winid).core_height
        return v:false
    endif
    if a:key ==# s:get('scrollup')
        call win_execute(a:winid, "normal! \<c-y>")
    elseif a:key ==# s:get('scrolldown')
        call win_execute(a:winid, "normal! \<c-e>")
    elseif a:key ==# s:get('top')
        call win_execute(a:winid, 'normal! gg')
    elseif a:key ==# s:get('bottom')
        call win_execute(a:winid, 'normal! G')
    else
        return v:false
    endif
    call popup_setoptions(a:winid, {'minheight': popup_getpos(a:winid).core_height})
    return v:true
endfunction

function s:close_cb_popup(fun, lnum, col, bufnr) abort
    if !a:bufnr
        return
    endif

    const buflines = getbufline(a:bufnr, 1, '$')
    const textwidth = len(buflines)
            \ ->range()
            \ ->map('strdisplaywidth(buflines[v:val])')
            \ ->max()

    " 2 for left+right padding + 1 for scrollbar = 3
    const width = textwidth + 3 > &columns ? &columns - 3 : textwidth
    const pos = screenpos(win_getid(), a:lnum, a:col)
    const col = &columns - pos.curscol < width ? &columns - width : pos.curscol
    const height = s:get('maxheight')

    let s:winid = a:fun(a:bufnr, {
            \ 'col': col,
            \ 'moved': 'any',
            \ 'minwidth': width,
            \ 'maxwidth': width,
            \ 'maxheight': height ? height : max([&lines - pos.row, pos.row]),
            \ 'wrap': v:true,
            \ 'highlight': 'CMakeHelp',
            \ 'padding': [],
            \ 'mapping': v:false,
            \ 'scrollbarhighlight': 'CMakeHelpScrollbar',
            \ 'scrollbarthumb': 'CMakeHelpThumb',
            \ 'filtermode': 'n',
            \ 'filter': funcref('s:popup_filter')
            \ })

    call setwinvar(s:winid, '&breakindent', 1)
endfunction

function s:close_cb_preview(mods, bufnr) abort
    if !a:bufnr || bufwinnr(bufname(a:bufnr)) > 0
        return
    endif
    silent execute a:mods 'pedit' fnameescape(bufname(a:bufnr))
endfunction

" Open CMake documentation for 'word' in the preview window
function cmakehelp#preview(mods, word) abort
    call s:openhelp(a:word, funcref('s:close_cb_preview', [a:mods]))
endfunction

" Open CMake documentation for 'word' in popup window at current cursor position
function cmakehelp#popup(word) abort
    if s:winid && !empty(popup_getpos(s:winid))
        call s:job_stop()
        call popup_close(s:winid)
        let s:winid = 0
    endif

    let s:lastword = a:word
    call s:openhelp(a:word, funcref('s:close_cb_popup', [
            \ function('popup_atcursor'),
            \ line('.'),
            \ col('.')
            \ ]))
endfunction

function cmakehelp#balloonexpr() abort
    if s:winid && !empty(popup_getpos(s:winid))
        if s:lastword == v:beval_text
            return ''
        endif
        call s:job_stop()
        call popup_close(s:winid)
        let s:winid = 0
    endif

    let s:lastword = v:beval_text
    call s:openhelp(v:beval_text, funcref('s:close_cb_popup', [
            \ function('popup_beval'),
            \ v:beval_lnum,
            \ v:beval_col
            \ ]))
    return ''
endfunction

" Open CMake documentation for 'word' in a browser
function cmakehelp#browser(word) abort
    if empty(s:version)
        call s:init_cmake_version()
    endif

    if empty(a:word)
        const url = 'https://cmake.org/cmake/help/' .. s:version
    else
        const group = s:getgroup(a:word)
        if empty(group)
            redraw
            return s:error('cmake-help: not a valid CMake keyword "%s"', a:word)
        endif

        const word = group ==# 'manual'
                \ ? substitute(a:word[:-2], '(', '.', '')
                \ : substitute(a:word, '<\|>', '', 'g')

        const url = group ==# 'property'
                \ ? printf('https://cmake.org/cmake/help/%s/manual/cmake-properties.7.html', s:version)
                \ : printf('https://cmake.org/cmake/help/%s/%s/%s.html', s:version, group, word)
    endif

    return job_start([&shell, &shellcmdflag, s:get('browser') .. ' ' .. url], {
            \ 'in_io': 'null',
            \ 'out_io': 'null',
            \ 'err_io': 'null',
            \ 'stoponexit': ''
            \ })
endfunction

function cmakehelp#complete(arglead, cmdline, cursorpos) abort
    return keys(s:lookup)->filter({_,i -> match(i, a:arglead) == 0})->sort()
endfunction

call s:init_lookup()

let &cpoptions = s:save_cpo
unlet s:save_cpo
