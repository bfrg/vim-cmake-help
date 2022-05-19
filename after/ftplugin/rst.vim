vim9script
# ==============================================================================
# View CMake documentation inside Vim
# File:         after/ftplugin/rst.vim
# Author:       bfrg <https://github.com/bfrg>
# Website:      https://github.com/bfrg/vim-cmake-help
# Last Change:  May 19, 2022
# License:      Same as Vim itself (see :h license)
# ==============================================================================

if bufname()[: 10] != 'CMake Help:'
    finish
endif

# Unfortunately Vim resets 'buflisted' every time a buffer is edited, see
# :h 'buflisted'
augroup cmakehelp
    autocmd! BufWinEnter <buffer> &l:buflisted = false
augroup END
