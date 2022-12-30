local telescope = require('telescope')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local config = require('telescope.config').values
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local utils = require('telescope.utils')
local olddirs = require('olddirs')

local default_config = {
  selected_dir_callback = vim.cmd.lcd,
}

local picker = function(opts)
  opts = vim.tbl_deep_extend('keep', opts or {}, default_config)

  local cwd = vim.fn.getcwd()

  pickers
    .new(opts, {
      prompt_title = 'Olddirs',
      finder = finders.new_table({
        results = olddirs.get(),
        entry_maker = opts.entry_maker or function(line)
          return {
            value = line,
            valid = line ~= cwd,
            ordinal = line,
            display = function(entry)
              return utils.transform_path(opts, entry.value)
            end,
          }
        end,
      }),
      sorter = config.file_sorter(opts),
      previewer = config.file_previewer(opts),
      attach_mappings = function(_, map)
        map({ 'i', 'n' }, '<cr>', function(prompt_bufnr)
          local dir = state.get_selected_entry().value
          actions.close(prompt_bufnr)
          -- allow previous name path_callback for backwards compatibility
          local selected_dir_callback = opts.path_callback or opts.selected_dir_callback
          selected_dir_callback(dir)
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  setup = function(ext_config, _)
    default_config = vim.tbl_deep_extend('force', default_config, ext_config)
  end,
  exports = {
    picker = picker,
  },
})
