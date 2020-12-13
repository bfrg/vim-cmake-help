# vim-cmake-help

View [CMake][cmake] documentation inside Vim (`>= 8.1.2250`).

The plugin provides three methods for quickly displaying CMake documentation:
1. Open the documentation in a new split window.
2. Open the documentation in a popup window at the current cursor position (or
   mouse pointer).
3. Open the [CMake Reference Documentation][cmake-doc] directly in your browser.

![out](https://user-images.githubusercontent.com/6266600/102029974-0954f300-3db1-11eb-848d-79750528e9f5.png)


## Usage

### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `:CMakeHelp {arg}`         | Open the CMake documentation for `{arg}` in a preview window. |
| `:CMakeHelpPopup {arg}`    | Open the CMake documentation for `{arg}` in a popup window.   |
| `:CMakeHelpOnline [{arg}]` | Open the online CMake documentation for `{arg}` in a browser. |

`{arg}` can be any standard CMake keyword. Use <kbd>TAB</kbd> in command-line
mode for argument completion and to get a list of supported keywords.

#### Example

To open the CMake documentation for the word under the cursor in a popup window with
<kbd>K</kbd>, add the following to `~/.vim/after/ftplugin/cmake.vim`:
```vim
setlocal keywordprg=:CMakeHelpPopup
```

### Mappings

For convenience, the following `<plug>` mapping can be used instead of the
commands:

| Mapping                    | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| `<plug>(cmake-help)`       | Open the CMake documentation for the word under the cursor in a preview window. |
| `<plug>(cmake-help-popup)` | Open the CMake documentation for the word under the cursor in a popup window.   |
| `<plug>(cmake-help-online)`| Open the online CMake documentation for the word under the cursor in a browser. |

#### Example

Add the following to `~/.vim/after/ftplugin/cmake.vim`:
```vim
" Open the online CMake documentation for current word in a browser
nmap <buffer> <leader>k <plug>(cmake-help-online)

" Open CMake documentation for current word in a preview window
nmap <buffer> <leader>K <plug>(cmake-help)
```

### Popup window

If the documentation doesn't fit into the popup window, a scrollbar will appear
on the right side. The popup window can then be scrolled with
<kbd>S-PageUp</kbd> and <kbd>S-PageDown</kbd>, or alternatively, using the mouse
wheel. Pressing <kbd>CTRL-C</kbd> or moving the cursor in any direction will
close the popup window.

The keys for scrolling the popup window are configurable.

### Mouse hovers

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

### `g:cmakehelp` and `b:cmakehelp`

Options can be set either through the buffer-local variable `b:cmakehelp`
(specified for `cmake` filetypes), or the global variable `g:cmakehelp`. The
variable must be a dictionary containing any of the following entries:

| Key           | Description                                                         | Default               |
| ------------- | ------------------------------------------------------------------- | --------------------- |
| `exe`         | Path to `cmake` executable.                                         | value found in `$PATH`|
| `browser`     | Browser executable.                                                 | `firefox`             |
| `scrollup`    | Key for scrolling the text up in the popup window.                  | <kbd>S-PageUp</kbd>   |
| `scrolldown`  | Key for scrolling the text down in the popup window.                | <kbd>S-PageDown</kbd> |
| `maxheight`   | Maximum height for popup window. Set to `0` for maximum available.  | `0`                   |
| `top`         | Key for jumping to the top of the buffer in the popup window.       | <kbd>S-Home</kbd>     |
| `bottom`      | Key for jumping to the botton of the buffer in the popup window.    | <kbd>S-End</kbd>      |

Example:
```vim
let g:cmakehelp = {
        \ 'exe': expand('~/.local/bin/cmake'),
        \ 'browser': 'xdg-open',
        \ 'maxheight': 20,
        \ 'scrollup': "\<c-k>",
        \ 'scrolldown': "\<c-j>",
        \ 'top': "\<c-t>",
        \ 'bottom': "\<c-g>"
        \ }
```

### Popup highlightings

The appearance of the popup window can be configured through the following
highlight groups:

| Highlight group     | Description                             | Default     |
| ------------------- | --------------------------------------- | ----------- |
| `CMakeHelp`         | Popup window background and normal text.| `Pmenu`     |
| `CMakeHelpScrollbar`| Scrollbar of popup window.              | `PmenuSbar` |
| `CMakeHelpThumb`    | Thumb of scrollbar.                     | `PmenuThumb`|


## Installation

```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-cmake-help
$ vim -u NONE -c 'helptags vim-cmake-help/doc | quit'
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`. Alternatively, use your favorite
plugin manager.


## License

Distributed under the same terms as Vim itself. See `:help license`.

[cmake]: https://cmake.org
[cmake-doc]: https://cmake.org/cmake/help/latest/index.html
