vim9script
# ==============================================================================
# View CMake documentation inside Vim
# File:         after/ftplugin/cmake.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-cmake-help
# Last Change:  May 19, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

import autoload '../../autoload/cmakehelp.vim' as ch

# Open CMake documentation in a preview window
command -buffer -nargs=1 -complete=customlist,ch.Complete CMakeHelp ch.Preview(<q-mods>, <q-args>)

# Open CMake documentation in a popup window
command -buffer -nargs=1 -complete=customlist,ch.Complete CMakeHelpPopup ch.Popup(<q-args>)

# Open CMake documentation in a browser
command -buffer -nargs=? -complete=customlist,ch.Complete CMakeHelpOnline ch.Browser(<q-args>)

nnoremap <buffer> <plug>(cmake-help)        <scriptcmd>ch.Preview('', expand('<cword>'))<cr>
nnoremap <buffer> <plug>(cmake-help-popup)  <scriptcmd>ch.Popup(expand('<cword>'))<cr>
nnoremap <buffer> <plug>(cmake-help-online) <scriptcmd>ch.Browser(expand('<cword>'))<cr>

b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute')
    .. ' | delc CMakeHelp'
    .. ' | delc CMakeHelpPopup'
    .. ' | delc CMakeHelpOnline'
    .. ' | execute "nunmap <buffer> <plug>(cmake-help)"'
    .. ' | execute "nunmap <buffer> <plug>(cmake-help-popup)"'
    .. ' | execute "nunmap <buffer> <plug>(cmake-help-online)"'
