# olddirs.nvim

olddirs.nvim is like [:oldfiles](https://neovim.io/doc/user/starting.html#%3Aoldfiles), but for
directories. It provides autocommands which store the current directory in an olddirs file when
Neovim starts or the directory is changed with [:cd](https://neovim.io/doc/user/editing.html#%3Acd),
[:lcd](https://neovim.io/doc/user/editing.html#%3Alcd), or
[:tcd](https://neovim.io/doc/user/editing.html#%3Atcd). The old directories can be retrieved as a
list of strings or through a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
picker.

## Motivation

I work in a large monorepo and change my working directory depending on what part of the codebase
I'm looking at to give my LSP (`gopls`) a chance and to improve the usefulness of fuzzy finding
files. I want to change the current working directory back to a previously used one without having
to configure a "project" or "workspace" beforehand. This requirement is not satisfied (as far as I
can tell) by existing similar plugins:

- [project.nvim](https://github.com/ahmedkhalf/project.nvim)
- [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim)
- [workspaces.nvim](https://github.com/natecraddock/workspaces.nvim)
- [neovim-session-manager](https://github.com/Shatur/neovim-session-manager)

olddirs.nvim is very lightweight and doesn't provide any niceties (out of the box\*) like some of
the above plugins, it's literally just `:oldfiles` for directories.

\* I say "out of the box" since some features like the searching or browsing of files inside a
previous directory can be implemented by adding actions to the olddirs.nvim Telescope picker.

## Documentation

Documentation can be found in [doc/olddirs.txt](doc/olddirs.txt) or by running `:help olddirs.nvim`.

## Getting started

### Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use('marcuscaisey/olddirs.nvim')
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'marcuscaisey/olddirs.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)

```viml
call dein#add('marcuscaisey/olddirs.nvim')
```

## Usage

### olddirs.get

The Lua API can be accessed by importing the `olddirs` module:

```lua
local olddirs = require('olddirs')
```

`olddirs.get()` returns the directories from the olddirs file in most recently used order.

### Telescope

> :information_source: The olddirs.nvim Telescope extension must be loaded before you can use the
> picker, see the [Telescope configuration](#telescope-1) section.

The old directories can also be accessed using the Telescope picker
`telescope.extensions.olddirs.picker({opts})` which works just like the [builtin oldfiles
picker](https://github.com/nvim-telescope/telescope.nvim#vim-pickers). `opts` can include generic
Telescope picker options.

Example mapping:

```lua
vim.keymap.set('n', '<leader>od', telescope.extensions.olddirs.picker)
```

## Configuration

### olddirs.nvim

> :information_source: The below example configuration is the default, so if you are happy with this
> then there's no need to call `olddirs.setup`.

```lua
local olddirs = require('olddirs')
olddirs.setup({
  file = vim.fn.stdpath('data') .. '/olddirs',
  limit = 100,
})
```

| Key     | Type     | Description                               |
| ------- | -------- | ----------------------------------------- |
| `file`  | `string` | The file to store the old directories in. |
| `limit` | `number` | The max number old directories to store.  |

### Telescope

To use the olddirs.nvim Telescope picker, you must load the extension:

```lua
telescope.load_extension('olddirs')
```

To configure the picker:

> :information_source: The below example configuration is the default, so if you are happy with this
> then there's no need to provide it to `telescope.setup`.

```lua
local telescope = require('telescope')
telescope.setup({
  extensions = {
    olddirs = {
      path_callback = vim.cmd.lcd,
      ...
    },
  },
})
```

| Key             | Type           | Description                                                    |
| --------------- | -------------- | -------------------------------------------------------------- |
| `path_callback` | `func({path})` | The function which will be called with the selected directory. |

You can also provide any generic picker config in this section. For example:

```lua
local telescope = require('telescope')
telescope.setup({
  extensions = {
    olddirs = {
      path_callback = olddirs.cd,
      layout_config = {
        width = 0.6,
        height = 0.9,
      },
      previewer = false,
      path_display = function(_, path)
        return path:gsub('^' .. os.getenv('HOME'), '~')
      end,
    },
  },
})
```
