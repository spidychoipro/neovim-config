local M = {}

local function module_not_found(module, err)
  return tostring(err):find("module '" .. module .. "' not found", 1, true) ~= nil
end

function M.load(module)
  local ok, result = pcall(require, module)
  if ok then
    return result
  end

  if not module_not_found(module, result) then
    vim.schedule(function()
      vim.notify(("Failed to load optional config '%s': %s"):format(module, result), vim.log.levels.WARN)
    end)
  end
end

return M
