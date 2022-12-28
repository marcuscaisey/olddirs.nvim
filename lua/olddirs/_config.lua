local M = {}

---@class Config
---@field file string
---@field limit number

---@type Config
local config = {
  file = vim.fn.stdpath('data') .. '/olddirs',
  limit = 100,
}

---Update the current config with the given values.
---@param opts Config
M.update = function(opts)
  config = vim.tbl_extend('force', config, opts)
end

---Return the current config.
---@return Config
M.get = function()
  return config
end

return M
