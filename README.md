# olddirs.nvim

olddirs.nvim is like [:oldfiles](https://neovim.io/doc/user/starting.html#%3Aoldfiles), but for
directories. It provides autocommands which store the current directory in an olddirs file when
Neovim starts or the directory is changed with [:cd](https://neovim.io/doc/user/editing.html#%3Acd),
[:lcd](https://neovim.io/doc/user/editing.html#%3Alcd), or
[:tcd](https://neovim.io/doc/user/editing.html#%3Atcd). The old directories can be retrieved as a
list of strings or through a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
picker.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Motivation](#motivation)
- [Documentation](#documentation)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)

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

## Installation

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
`telescope.extensions.olddirs.picker({opts})`. `{opts}` can include regular Telescope options like
`layout_config`, `attach_mappings`, and `path_display` as well as the olddirs.nvim specific option
`selected_dir_callback`:

| Key                     | Type          | Description                                                    |
| ----------------------- | ------------- | -------------------------------------------------------------- |
| `selected_dir_callback` | `func({dir})` | The function which will be called with the selected directory. |

### Example mappings

#### Default settings

```lua
local telescope = require('telescope')

vim.keymap.set('n', '<leader>od', telescope.extensions.olddirs.picker)
```

#### Overriding `selected_dir_callback`

```lua
local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- Opens the Telescope find_files picker in the selected directory.
vim.keymap.set('n', '<leader>ofd', function()
  telescope.extensions.olddirs.picker({
    selected_dir_callback = function(dir)
      builtin.find_files({
        prompt_title = 'Find Files in ' .. dir,
        cwd = dir,
      })
    end,
  })
end)
-- Opens the Telescope live_grep picker in the selected directory.
vim.keymap.set('n', '<leader>ogd', function()
  telescope.extensions.olddirs.picker({
    selected_dir_callback = function(dir)
      builtin.live_grep({
        prompt_title = 'Live Grep in ' .. dir,
        search_dirs = { dir },
      })
    end,
  })
end)
```

#### Providing `attach_mappings`

```lua
local telescope = require('telescope')
local state = require('telescope.actions.state')
local builtin = require('telescope.builtin')

-- <c-p> opens the Telescope find_files picker in the selected directory.
-- <c-g> opens the Telescope live_grep picker in the selected directory.
vim.keymap.set('n', '<leader>od', function()
  telescope.extensions.olddirs.picker({
    attach_mappings = function(_, map)
      map({ 'i', 'n' }, '<c-p>', function()
        local dir = state.get_selected_entry().value
        builtin.find_files({
          prompt_title = 'Find Files in ' .. dir,
          cwd = dir,
        })
      end)
      map({ 'i', 'n' }, '<c-g>', function()
        local dir = state.get_selected_entry().value
        builtin.live_grep({
          prompt_title = 'Live Grep in ' .. dir,
          search_dirs = { dir },
        })
      end)
      return true
    end,
  })
end)
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
      selected_dir_callback = vim.cmd.lcd,
      ...
    },
  },
})
```

You can also provide any generic picker config in this section. For example:

```lua
local telescope = require('telescope')
telescope.setup({
  extensions = {
    olddirs = {
      selected_dir_callback = vim.cmd.cd,
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
