local M = {}

---@type OlddirsConfig
local default_config = {
  file = vim.fn.stdpath('data') .. '/olddirs',
  limit = 100,
}

---@type OlddirsConfig
local config = default_config

---@param opts OlddirsConfig
M.set = function(opts)
  config = vim.tbl_extend('force', default_config, opts)
end

---@return OlddirsConfig
M.get = function()
  return config
end

return M
