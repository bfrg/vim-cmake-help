# vim-cmake-help

View CMake documentation inside Vim.


## Usage

#### Commands

| Command                    | Description                                                   |
| -------------------------- | ------------------------------------------------------------- |
| `:CMakeHelp {arg}`         | Open the CMake documentation for `{arg}` in a `previewwindow`.|
| `:CMakeHelpOnline [{arg}]` | Open the online CMake documentation for `{arg}` in a browser. |


#### Mappings

| Mapping                    | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| `<plug>(cmake-help)`       | Open the CMake documentation for word under cursor in a `previewwindow`. |
| `<plug>(cmake-help-online)`| Open the online CMake documentation for word under cursor in a browser.  |


## Configuration

#### `g:cmakehelp` and `b:cmakehelp`

Options can be set in either the buffer-local dictionary `b:cmakehelp`
(specified for `cmake` filetypes), or the global dictionary `g:cmakehelp`. The
following entries can be set:

| Key       | Description                 | Default                 |
| --------- | --------------------------- | ----------------------- |
| `exe`     | Path to `cmake` executable  | value found in `$PATH`  |
| `browser` | Browser executable          | `firefox`               |


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
