---@brief [[
---*olddirs.nvim*
---A wrapper around |:cd|, |:lcd|, |:tcd| which stores the changed to directories
---in an olddirs file so that they can be retrieved later.
---@brief ]]

local olddirs = {}

local config = {
  file = vim.fn.stdpath('data') .. '/olddirs',
  limit = 100,
}

local cd_and_save_path = function(cd_func, path)
  path = vim.fs.normalize(path)
  cd_func(vim.fn.fnameescape(path))

  local paths = { path }
  local f = io.open(config.file, 'r')
  if f then
    for line in f:lines() do
      if line ~= path then
        table.insert(paths, line)
      end
    end
    f:close()
  end

  f = assert(io.open(config.file, 'w+'))
  local file_content = table.concat(paths, '\n', 1, math.min(config.limit, #paths))
  assert(f:write(file_content))
  f:close()
end

---Configure olddirs.nvim. This is only required if you want to change the
---defaults.
---@param opts table options
---  * {file} (string): file to store the olddirs in
---    (default ~/.local/share/nvim/olddirs)
---  * {limit} (number): max number of dirs to store in the olddirs file
---    (default 100)
olddirs.setup = function(opts)
  vim.tbl_extend('force', config, opts)
end

---Wrapper around |:cd| which saves {path} to the olddirs file.
---@param path string The target directory.
olddirs.cd = function(path)
  cd_and_save_path(vim.cmd.cd, path)
end

---Wrapper around |:lcd| which saves {path} to the olddirs file.
---@param path string The target directory.
olddirs.lcd = function(path)
  cd_and_save_path(vim.cmd.lcd, path)
end

---Wrapper around |:tcd| which saves {path} to the olddirs file.
---@param path string The target directory.
olddirs.tcd = function(path)
  cd_and_save_path(vim.cmd.tcd, path)
end

---Returns the directories from the olddirs file if it exists, otherwise an
---empty table. Directories are ordered in most recently used order.
---@return table
olddirs.get = function()
  local f = io.open(config.file, 'r')
  if not f then
    return {}
  end
  local dirs = {}
  for line in f:lines() do
    table.insert(dirs, line)
  end
  f:close()
  return dirs
end

return olddirs
