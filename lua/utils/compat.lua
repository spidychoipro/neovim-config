local M = {}

function M.validate_spec(spec, user_config, path)
  local keys = vim.tbl_keys(spec)
  table.sort(keys)

  for _, key in ipairs(keys) do
    local rule = spec[key]
    local optional = rule[3]
    local message = rule[4]

    if type(optional) == "string" and message == nil then
      message = optional
      optional = false
    end

    local ok, err = pcall(vim.validate, key, rule[1], rule[2], optional, message)
    if not ok then
      return false, string.format("%s: %s", path, err)
    end
  end

  local errors = {}
  for key, _ in pairs(user_config or {}) do
    if not spec[key] then
      table.insert(errors, string.format("'%s' is not a valid key of %s", key, path))
    end
  end

  if #errors == 0 then
    return true, nil
  end

  return false, table.concat(errors, "\n")
end

function M.with_legacy_validate(callback)
  local original_validate = vim.validate

  vim.validate = function(name, value, validator, optional, message)
    if type(name) == "table" and value == nil then
      local keys = vim.tbl_keys(name)
      table.sort(keys)

      for _, key in ipairs(keys) do
        local rule = name[key]
        original_validate(key, rule[1], rule[2], rule[3], rule[4])
      end

      return
    end

    return original_validate(name, value, validator, optional, message)
  end

  local results = { xpcall(callback, debug.traceback) }
  vim.validate = original_validate

  if not results[1] then
    error(results[2], 0)
  end

  return unpack(results, 2)
end

return M
