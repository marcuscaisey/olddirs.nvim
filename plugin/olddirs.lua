if LoadedOlddirs then
  return
end

LoadedOlddirs = true

local config = require('olddirs._config')

local save_dir = function(dir)
  dir = vim.fs.normalize(dir)

  local olddirs = { dir }
  local f = io.open(config.get().file, 'r')
  if f then
    for line in f:lines() do
      if line ~= dir then
        table.insert(olddirs, line)
      end
    end
    f:close()
  end

  f = assert(io.open(config.get().file, 'w+'))
  local file_content = table.concat(olddirs, '\n', 1, math.min(config.get().limit, #olddirs))
  assert(f:write(file_content))
  f:close()
end

local group = vim.api.nvim_create_augroup('olddirs', { clear = true })

vim.api.nvim_create_autocmd({ 'DirChanged' }, {
  callback = function()
    save_dir(vim.v.event.cwd)
  end,
  group = group,
  desc = 'Save the changed to directory to the olddirs file',
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  callback = function()
    save_dir(vim.fn.getcwd())
  end,
  group = group,
  desc = 'Save the current working directory to the olddirs file on startup',
})
