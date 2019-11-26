# vim-cmake-help

View CMake documentation inside Vim.


## Usage

#### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `:CMakeHelp {arg}`         | Open the CMake documentation for `{arg}` in a `previewwindow`.|
| `:CMakeHelpPopup {arg}`    | Open the CMake documentation for `{arg}` in a popup window.   |
| `:CMakeHelpOnline [{arg}]` | Open the online CMake documentation for `{arg}` in a browser. |


#### Mappings

| Mapping                    | Description                                                                      |
| -------------------------- | -------------------------------------------------------------------------------- |
| `<plug>(cmake-help)`       | Open the CMake documentation for the word under the cursor in a `previewwindow`. |
| `<plug>(cmake-help-popup)` | Open the CMake documentation for the word under the cursor in a popup window.    |
| `<plug>(cmake-help-online)`| Open the online CMake documentation for the word under the cursor in a browser.  |


## Configuration

#### `g:cmakehelp` and `b:cmakehelp`

Options can be set either through the buffer-local variable `b:cmakehelp`
(specified for `cmake` filetypes), or the global variable `g:cmakehelp`. The
variable must be a dictionary containing any of the following entries:

| Key           | Description                                                         | Default               |
| ------------- | ------------------------------------------------------------------- | --------------------- |
| `exe`         | Path to `cmake` executable.                                         | value found in `$PATH`|
| `browser`     | Browser executable.                                                 | `firefox`             |
| `title`       | Display a title at the top of the popup window.                     | `0`                   |
| `close`       | Mouse event for closing the popup window: `click`, `button`, `none` | `none`                |
| `scrollbar`   | Display a scrollbar in the popup window.                            | `1`                   |
| `minwidth`    | Minimum width of popup window.                                      | `60`                  |
| `maxwidth`    | Maximum width of popup window.                                      | `90`                  |
| `minheight`   | Minimum height of popup window.                                     | `5`                   |
| `maxheight`   | Maximum height of popup window.                                     | `30`                  |
| `scrollup`    | Key for scrolling up the popup window.                              | <kbd>S-PageUp</kbd>   |
| `scrolldown`  | Key for scrolling down the popup window.                            | <kbd>S-PageDown</kbd> |
| `top`         | Key for jumping to the top of buffer in the popup window.           | <kbd>S-Home</kbd>     |
| `bottom`      | Key for jumping to the botton of buffer in the popup window.        | <kbd>S-End</kbd>      |

#### Popup window highlightings

The appearance of the popup window can be configured through the following
highlight groups:

| Highlight group     | Description                             | Default     |
| ------------------- | --------------------------------------- | ----------- |
| `CMakeHelp`         | Popup window background and error text. | `Pmenu`     |
| `CMakeHelpTitle`    | Title of popup window.                  | `Pmenu`     |
| `CMakeHelpScrollbar`| Scrollbar of popup window.              | `PmenuSbar` |
| `CMakeHelpThumb`    | Thumb of scrollbar.                     | `PmenuThumb`|


## Installation

#### Manual Installation

```bash
$ cd ~/.vim/pack/git-plugins/start
$ git clone https://github.com/bfrg/vim-cmake-help
$ vim -u NONE -c "helptags vim-qf-tooltip/doc" -c q
```
**Note:** The directory name `git-plugins` is arbitrary, you can pick any other
name. For more details see `:help packages`.

#### Plugin Managers

Assuming [vim-plug][plug] is your favorite plugin manager, add the following to
your `vimrc`:
```vim
Plug 'bfrg/vim-cmake-help'
```


## License

Distributed under the same terms as Vim itself. See `:help license`.

[plug]: https://github.com/junegunn/vim-plug
