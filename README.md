# vim-cmake-help

View [CMake][cmake] documentation inside Vim.

The plugin provides three methods for quickly displaying CMake documentation:
1. Open the documentation in a new split window.
2. Open the documentation in a popup window at the current cursor (or mouse
   pointer) position.
3. Open the [CMake Reference Documentation][cmake-doc] directly in your browser.

<dl>
  <p align="center">
  <a href="https://asciinema.org/a/283915">
    <img src="https://asciinema.org/a/283915.png" width="480">
  </a>
  </p>
</dl>


## Requirements

Vim `>= 8.1.2250`


## Usage

#### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `:CMakeHelp {arg}`         | Open the CMake documentation for `{arg}` in a `previewwindow`.|
| `:CMakeHelpPopup {arg}`    | Open the CMake documentation for `{arg}` in a popup window.   |
| `:CMakeHelpOnline [{arg}]` | Open the online CMake documentation for `{arg}` in a browser. |

For example, running `:CMakeHelpOnline target_compile_options` opens the
documentation for [target\_compile\_options][target_compile_options] in your
browser.

You can set `keywordprg` directly to one of the commands. For instance, to open
the CMake documentation for the word under the cursor in a popup window, add the
following to `~/.vim/after/ftplugin/cmake.vim`:
```vim
" Open CMake documentation for current word with K
setlocal keywordprg=:CMakeHelpPopup
```

The popup window is closed when the cursor is moved outside the current word. It
can also be closed by pressing <kbd>CTRL-C</kbd>.

#### Mappings

| Mapping                    | Description                                                                      |
| -------------------------- | -------------------------------------------------------------------------------- |
| `<plug>(cmake-help)`       | Open the CMake documentation for the word under the cursor in a `previewwindow`. |
| `<plug>(cmake-help-popup)` | Open the CMake documentation for the word under the cursor in a popup window.    |
| `<plug>(cmake-help-online)`| Open the online CMake documentation for the word under the cursor in a browser.  |

Example mappings:
```vim
" Open CMake documentation for current word in a popup window by pressing K
setlocal keywordprg=:CMakeHelpPopup

" Open online CMake documentation for current word in a browser
nmap <buffer> <leader>k <plug>(cmake-help-online)

" Open CMake documentation for current word in a preview window
nmap <buffer> <leader>K <plug>(cmake-help)
```

#### Mouse hovers

The plugin provides a `balloonexpr` that will open the CMake documentation for
the word under the mouse pointer in a popup window. To enable this feature, add
the following to `~/.vim/after/ftplugin/cmake.vim`:
```vim
setlocal ballooneval
setlocal balloonevalterm
setlocal balloonexpr=cmakehelp#balloonexpr()
```
Moving the mouse pointer outside the current word closes the popup window.


## Configuration

#### `g:cmakehelp` and `b:cmakehelp`

Options can be set either through the buffer-local variable `b:cmakehelp`
(specified for `cmake` filetypes), or the global variable `g:cmakehelp`. The
variable must be a dictionary containing any of the following entries:

| Key           | Description                                                         | Default               |
| ------------- | ------------------------------------------------------------------- | --------------------- |
| `exe`         | Path to `cmake` executable.                                         | value found in `$PATH`|
| `browser`     | Browser executable.                                                 | `firefox`             |
| `scrollbar`   | Display a scrollbar in the popup window.                            | `1`                   |
| `minwidth`    | Minimum width of popup window.                                      | `60`                  |
| `maxwidth`    | Maximum width of popup window.                                      | `90`                  |
| `minheight`   | Minimum height of popup window.                                     | `5`                   |
| `maxheight`   | Maximum height of popup window.                                     | `30`                  |
| `scrollup`    | Key for scrolling the text up in the popup window.                  | <kbd>S-PageUp</kbd>   |
| `scrolldown`  | Key for scrolling the text down in the popup window.                | <kbd>S-PageDown</kbd> |
| `top`         | Key for jumping to the top of the buffer in the popup window.       | <kbd>S-Home</kbd>     |
| `bottom`      | Key for jumping to the botton of the buffer in the popup window.    | <kbd>S-End</kbd>      |

Example:
```vim
let g:cmakehelp = {
    \ 'exe': expand('~/.local/bin/cmake'),
    \ 'browser': 'open',
    \ 'minwidth': 70,
    \ 'maxwidth': 70,
    \ 'minheight': 15,
    \ 'maxheight': 15
}
```

#### Popup highlightings

The appearance of the popup window can be configured through the following
highlight groups:

| Highlight group     | Description                             | Default     |
| ------------------- | --------------------------------------- | ----------- |
| `CMakeHelp`         | Popup window background and normal text.| `Pmenu`     |
| `CMakeHelpScrollbar`| Scrollbar of popup window.              | `PmenuSbar` |
| `CMakeHelpThumb`    | Thumb of scrollbar.                     | `PmenuThumb`|


## Installation

#### Manual Installation

```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-cmake-help
$ vim -u NONE -c "helptags vim-cmake-help/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`.

#### Plugin Managers

Assuming [vim-plug][plug] is your favorite plugin manager, add the following to
your `vimrc`:
```vim
if has('patch-8.1.2250')
    Plug 'bfrg/vim-cmake-help'
endif
```


## License

Distributed under the same terms as Vim itself. See `:help license`.

[plug]: https://github.com/junegunn/vim-plug
[cmake]: https://cmake.org
[cmake-doc]: https://cmake.org/cmake/help/latest/index.html
[target_compile_options]: https://cmake.org/cmake/help/v3.16/command/target_compile_options.html
