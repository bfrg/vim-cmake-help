vim9script
# ==============================================================================
# View CMake documentation inside Vim
# File:         autoload/cmakehelp.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-cmake-help
# Last Change:  May 19, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

highlight default link CMakeHelp           Pmenu
highlight default link CMakeHelpScrollbar  PmenuSbar
highlight default link CMakeHelpThumb      PmenuThumb

const defaults: dict<any> = {
    exe: 'cmake',
    browser: 'firefox',
    scrollup: "\<s-pageup>",
    scrolldown: "\<s-pagedown>",
    top: "\<s-home>",
    bottom: "\<s-end>",
    maxheight: 0
}

# Lookup table to obtain the group (or category) of a CMake keyword, for
# example:
#
#   keywordmap['set_target_properties'] -> 'command'
#
var keywordmap: dict<string> = {}

# CMake version, like v3.15, or 'latest'
var version: string = ''

# Last word the cursor was on; required for balloonevalexpr
var lastword: string = ''

# window ID of displayed popup window
var popup_id: number = 0

# Job object for cmake commands
var cmake_job: job

# Job object for BROWSER commands
var browser_job: job

def ErrorMsg(msg: string)
    redraw
    echohl ErrorMsg
    echomsg msg
    echohl None
enddef

# Check order: b:cmakehelp -> g:cmakehelp -> defaults
def Getopt(key: string): any
    return get(b:, 'cmakehelp', get(g:, 'cmakehelp', {}))->get(key, defaults[key])
enddef

# Get the group of a CMake keyword
def Getgroup(word: string): string
    return get(keywordmap, word, get(keywordmap, tolower(word), ''))
enddef

# Get the name of a CMake help buffer
def Bufname(group: string, word: string): string
    return $'CMake Help: {word} [{group}]'
enddef

# Obtain CMake version from 'cmake --version'
def Init_cmake_version()
    const output = systemlist($'{Getopt('exe')} --version')[0]
    if v:shell_error
        version = 'latest'
        return
    endif
    version = 'v' .. matchstr(output, '\c^\s*cmake\s\+version\s\+\zs\d\.\d\+\ze.*$')
enddef

# Initialize lookup-table for finding the group (command, property, variable) of
# a CMake keyword
def Init_lookup()
    const groups: list<string> = ['command', 'manual', 'module', 'policy', 'property', 'variable']
    var words: list<string>
    for i in groups
        silent words = systemlist($'{Getopt('exe')} --help-{i}-list')
        for k in words
            keywordmap[k] = i
        endfor
    endfor
enddef

# 'Cb' is called after the channel is closed and its output has been read. The
# output will be appended to a prepared buffer. 'Cb' is called with one
# argument, the buffer number of the prepared buffer and is supposed to open a
# window with the passed buffer (popup window or normal window)
def Openhelp(word: string, Cb: func(number))
    if empty(word)
        return
    endif

    const group: string = Getgroup(word)
    if empty(group)
        ErrorMsg($'[cmake-help] Sorry, no help for "{word}"')
        return
    endif

    const bufname: string = Bufname(group, word)

    # Note: when CTRL-O is pressed, Vim automatically adds old 'CMake Help'
    # buffers to the buffer list, see :ls!, which will be unloaded and empty
    if !bufexists(bufname) || (bufexists(bufname) && !bufloaded(bufname))
        if job_status(cmake_job) == 'run'
            job_stop(cmake_job)
        endif

        cmake_job = job_start([Getopt('exe'), $'--help-{group}', word], {
            out_mode: 'raw',
            in_io: 'null',
            err_cb: (_, msg) => ErrorMsg($'[cmake-help] {msg}'),
            close_cb: funcref(Close_cb, [Cb, bufname])
        })
        return
    endif

    # Buffer already exists with content, we don't have to call CMake again
    Cb(bufnr(bufname))
enddef

def Close_cb(Cb: func, bufname: string, ch: channel)
    var output: list<string> = []
    if ch_status(ch, {part: 'out'}) == 'buffered'
        extend(output, ch->ch_readraw()->split('\n'))
    endif

    if empty(output)
        return
    endif

    const bufnr: number = bufadd(bufname)
    silent bufload(bufnr)
    setbufvar(bufnr, '&swapfile', false)
    setbufvar(bufnr, '&buftype', 'nofile')
    setbufvar(bufnr, '&bufhidden', 'hide')
    setbufvar(bufnr, '&filetype', 'rst')
    setbufline(bufnr, 1, output)
    setbufvar(bufnr, '&modifiable', false)
    setbufvar(bufnr, '&readonly', true)
    Cb(bufnr)
enddef

def Popup_filter(winid: number, key: string): bool
    if line('$', winid) == popup_getpos(winid).core_height
        return false
    endif
    if key == Getopt('scrollup')
        win_execute(winid, "normal! \<c-y>")
    elseif key == Getopt('scrolldown')
        win_execute(winid, "normal! \<c-e>")
    elseif key == Getopt('top')
        win_execute(winid, 'normal! gg')
    elseif key == Getopt('bottom')
        win_execute(winid, 'normal! G')
    else
        return false
    endif
    popup_setoptions(winid, {minheight: popup_getpos(winid).core_height})
    return true
enddef

def Close_cb_popup(Func: func(any, dict<any>): number, lnum: number, column: number, bufnr: number)
    if bufnr == 0
        return
    endif

    const buflines: list<string> = getbufline(bufnr, 1, '$')
    const textwidth: number = buflines
        ->len()
        ->range()
        ->map((_, i: number) => strdisplaywidth(buflines[i]))
        ->max()

    # 2 for left+right padding + 1 for scrollbar = 3
    const width: number = textwidth + 3 > &columns ? &columns - 3 : textwidth
    const pos: dict<number> = win_getid()->screenpos(lnum, column)
    const col: number = &columns - pos.curscol < width ? &columns - width : pos.curscol
    const height: number = Getopt('maxheight')

    popup_id = Func(bufnr, {
        col: col,
        moved: 'any',
        minwidth: width,
        maxwidth: width,
        maxheight: height > 0 ? height : max([&lines - pos.row, pos.row]),
        wrap: true,
        highlight: 'CMakeHelp',
        padding: [],
        mapping: false,
        scrollbarhighlight: 'CMakeHelpScrollbar',
        scrollbarthumb: 'CMakeHelpThumb',
        filtermode: 'n',
        filter: Popup_filter
    })

    setwinvar(popup_id, '&breakindent', true)
enddef

def Close_cb_preview(mods: string, bufnr: number)
    if !bufnr || bufnr->bufname()->bufwinnr() > 0
        return
    endif
    silent execute $'{mods} pedit {bufnr->bufname()->fnameescape()}'
enddef

# Open CMake documentation for 'word' in the preview window
export def Preview(mods: string, word: string)
    Openhelp(word, funcref(Close_cb_preview, [mods]))
enddef

# Open CMake documentation for 'word' in popup window at current cursor position
export def Popup(word: string)
    if popup_id > 0 && !popup_id->popup_getpos()->empty()
        popup_close(popup_id)
        popup_id = 0
    endif

    lastword = word
    Openhelp(word, funcref(Close_cb_popup, [function('popup_atcursor'), line('.'), col('.')]))
enddef

export def Balloonexpr(): string
    if popup_id > 0 && !popup_id->popup_getpos()->empty()
        if lastword == v:beval_text
            return ''
        endif
        popup_close(popup_id)
        popup_id = 0
    endif

    lastword = v:beval_text
    Openhelp(v:beval_text, funcref(Close_cb_popup, [function('popup_beval'), v:beval_lnum, v:beval_col]))
    return ''
enddef

# Open CMake documentation for 'word' in a browser
export def Browser(word: string)
    if version == ''
        Init_cmake_version()
    endif

    var url: string

    if word == ''
        url = $'https://cmake.org/cmake/help/{version}'
    else
        const group: string = Getgroup(word)
        if group == ''
            ErrorMsg($'[cmake-help] not a valid CMake keyword "{word}"')
            return
        endif

        const w = group == 'manual'
            ? substitute(word[: -2], '(', '.', '')
            : substitute(word, '<\|>', '', 'g')

        url = group == 'property'
            ? $'https://cmake.org/cmake/help/{version}/manual/cmake-properties.7.html'
            : $'https://cmake.org/cmake/help/{version}/{group}/{w}.html'
    endif

    browser_job = job_start([Getopt('browser'), url], {
        in_io: 'null',
        out_io: 'null',
        err_io: 'null',
        stoponexit: ''
    })
enddef

export def Complete(arglead: string, cmdline: string, cursorpos: number): list<string>
    return keywordmap
        ->keys()
        ->filter((_, i: string): bool => match(i, arglead) == 0)
        ->sort()
enddef

Init_lookup()
