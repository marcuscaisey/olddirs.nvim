local telescope = require('telescope')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local config = require('telescope.config').values
local olddirs = require('olddirs')

local default_config = {
  path_callback = vim.cmd.lcd,
}

local picker = function(opts)
  opts = vim.tbl_deep_extend('keep', opts or {}, default_config)

  local current_cwd = vim.fn.getcwd()
  local paths = vim.tbl_filter(function(path)
    return path ~= current_cwd
  end, olddirs.get())

  pickers
    .new(opts, {
      prompt_title = 'Olddirs',
      finder = finders.new_table({
        results = paths,
        entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
      }),
      sorter = config.file_sorter(opts),
      previewer = config.file_previewer(opts),
      attach_mappings = function(_, map)
        map({ 'i', 'n' }, '<cr>', function(prompt_bufnr)
          local entry = state.get_selected_entry()
          actions.close(prompt_bufnr)
          opts.path_callback(entry.path)
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
