---@brief [[
---*olddirs.nvim*
---olddirs.nvim is like |:oldfiles|, but for directories.
---@brief ]]

---@toc olddirs-contents

---@mod olddirs-intro INTRODUCTION
---@brief [[
---olddirs.nvim provides |autocommand|s which store the current directory in an
---olddirs file when Neovim starts or the directory is changed with |:cd|,
---|:lcd|, or |:tcd|. The old directories can be retrieved as a list of strings
---or through a |telescope.nvim| picker.
---@brief ]]

---@mod olddirs OLDDIRS

local config = require('olddirs._config')

local olddirs = {}

---@class OlddirsConfig
---@field file string File to store the old directories in.
---@field limit number Max number of directories to store in the olddirs file.

---Configures olddirs.nvim.
---This is only required if you want to change the defaults which are shown
---below.
---@param opts OlddirsConfig
---@usage [[
---local olddirs = require('olddirs')
---olddirs.setup({
---  file = vim.fn.stdpath('data') .. '/olddirs',
---  limit = 100,
---})
---@usage ]]
olddirs.setup = function(opts)
  config.set(opts)
end

---Returns the directories from the olddirs file if it exists, otherwise an
---empty table.
---@return string[] directories directories in most recently used order
---@usage [[
---local olddirs = require('olddirs')
---vim.pretty_print(olddirs.get())
---@usage ]]
olddirs.get = function()
  local f = io.open(config.get().file, 'r')
  if not f then
    return {}
  end
  local dirs = {}
  for line in f:lines() do
    if vim.uv.fs_stat(line) then
      table.insert(dirs, line)
    end
  end
  f:close()
  return dirs
end

---@private
---@class olddirs.FzfPickerConfig: fzf-lua.config.Base
---@field selected_dir_callback fun(string)
---@field git_repo_only boolean

---@class olddirs.FzfPickerOpts: olddirs.FzfPickerConfig
---@field selected_dir_callback? fun(string) The function which will be called with the selected directory.
---@field git_repo_only? boolean Only show directories in the current git repository.

---@param opts olddirs.FzfPickerOpts?
function olddirs.fzf_picker(opts)
  local fzf = require('fzf-lua')
  local actions = require('fzf-lua.actions')
  local config = require('fzf-lua.config')
  local make_entry = require('fzf-lua.make_entry')

  if not fzf.defaults.olddirs then
    fzf.defaults.olddirs = {
      selected_dir_callback = vim.cmd.lcd,
      git_repo_only = false,
    }
  end

  opts = opts or {}
  vim.validate('opts.selected_dir_callback', opts.selected_dir_callback, 'function', true)
  vim.validate('opts.git_repo_only', opts.git_repo_only, 'boolean', true)

  opts = config.normalize_opts(opts, 'olddirs')
  opts = vim.tbl_deep_extend('keep', opts, {
    actions = {
      ['enter'] = {
        fn = function(dir)
          opts.selected_dir_callback(dir)
        end,
        desc = 'select-dir',
      },
      ['alt-g'] = {
        fn = function(_, opts)
          actions.toggle_opt(opts, 'git_repo_only')
        end,
        desc = 'toggle-git-repo-only',
        reuse = true,
      },
    },
  })

  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast opts olddirs.FzfPickerConfig

  local dirs = vim.iter(olddirs.get())

  local cwd = vim.fn.getcwd()
  dirs:filter(function(dir)
    return dir ~= cwd
  end)

  if opts.git_repo_only then
    local git_path = vim.fs.find('.git', { upward = true })[1]
    if git_path then
      local repo_root = vim.fs.dirname(git_path)
      dirs:filter(function(dir)
        return vim.fs.relpath(repo_root, dir) ~= nil
      end)
    end
  end

  dirs:map(function(dir)
    return make_entry.file(dir, opts)
  end)

  fzf.fzf_exec(dirs:totable(), opts)
end

---@mod olddirs-telescope TELESCOPE
---@brief [[
---Old directories can also be accessed through the |telescope.nvim| picker. To
---do so, you must first load the extension:
--->lua
---  telescope.load_extension('olddirs')
---<
---
---To open the picker, call `telescope.extensions.olddirs.picker({opts})`.
---`{opts}` can include regular Telescope options like `layout_config` and
---`path_display`.
---
---To configure the picker, include the configuration in a call to
---`telescope.setup({opts})`:
--->lua
---  telescope.setup({
---    extensions = {
---      olddirs = {
---        selected_dir_callback = vim.cmd.lcd,
---        git_repo_only = false,
---      },
---    },
---  })
---<
---* `selected_dir_callback({dir})` is the function which will be called with the
---  selected directory.
---* `git_repo_only` indicates whether to only show directories in the current
---  git repository.
---
---The above configuration is the default, so if you're happy with it then
---there's no need to include it in a call to `telescope.setup({opts})`.
---
---
---You can also provide any generic picker config in this section. For example:
--->lua
---  telescope.setup({
---    extensions = {
---      olddirs = {
---        selected_dir_callback = vim.cmd.cd,
---        layout_config = {
---          width = 0.6,
---          height = 0.9,
---        },
---        previewer = false,
---        path_display = function(_, path)
---          return path:gsub('^' .. os.getenv('HOME'), '~')
---        end,
---      },
---    },
---  })
---<
---@brief ]]

---@mod olddirs-example-mappings EXAMPLE MAPPINGS
---@brief [[
---Default settings ~
--->lua
---  local telescope = require('telescope')
---
---  vim.keymap.set('n', '<leader>od', telescope.extensions.olddirs.picker)
---<
---
---Overriding `selected_dir_callback` ~
--->lua
---  local telescope = require('telescope')
---  local builtin = require('telescope.builtin')
---
---  -- Opens the Telescope find_files picker in the selected directory.
---  vim.keymap.set('n', '<leader>ofd', function()
---    telescope.extensions.olddirs.picker({
---      selected_dir_callback = function(dir)
---        builtin.find_files({
---          prompt_title = 'Find Files in ' .. dir,
---          cwd = dir,
---        })
---      end,
---    })
---  end)
---  -- Opens the Telescope live_grep picker in the selected directory.
---  vim.keymap.set('n', '<leader>ogd', function()
---    telescope.extensions.olddirs.picker({
---      selected_dir_callback = function(dir)
---        builtin.live_grep({
---          prompt_title = 'Live Grep in ' .. dir,
---          search_dirs = { dir },
---        })
---      end,
---    })
---  end)
---<
---
---Providing `attach_mappings` ~
--->lua
---  local telescope = require('telescope')
---  local state = require('telescope.actions.state')
---  local builtin = require('telescope.builtin')
---
---  -- <c-p> opens the Telescope find_files picker in the selected directory.
---  -- <c-g> opens the Telescope live_grep picker in the selected directory.
---  vim.keymap.set('n', '<leader>od', function()
---    telescope.extensions.olddirs.picker({
---      attach_mappings = function(_, map)
---        map({ 'i', 'n' }, '<c-p>', function()
---          local dir = state.get_selected_entry().value
---          builtin.find_files({
---            prompt_title = 'Find Files in ' .. dir,
---            cwd = dir,
---          })
---        end)
---        map({ 'i', 'n' }, '<c-g>', function()
---          local dir = state.get_selected_entry().value
---          builtin.live_grep({
---            prompt_title = 'Live Grep in ' .. dir,
---            search_dirs = { dir },
---          })
---        end)
---        return true
---      end,
---    })
---  end)
---<
---@brief ]]

return olddirs
