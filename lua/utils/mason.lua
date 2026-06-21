local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

function M.get_package_path(package_name)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return nil
  end
  local ok_pkg, pkg = pcall(registry.get_package, registry, package_name)
  if not ok_pkg then
    return nil
  end
  return pkg:get_install_path()
end

function M.find_bin(package_name, binary_name)
  local package_path = M.get_package_path(package_name)
  if not package_path then
    return nil
  end

  local matches = vim.fn.glob(vim.fs.joinpath(package_path, "**", binary_name), false, true)
  if #matches > 0 then
    return matches[1]
  end

  return nil
end

function M.find_bin_with_fallback(package_name, binary_name, known_relative_path)
  local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
  for _, ext in ipairs({ ".cmd", ".exe", ".bat", "" }) do
    local candidate = vim.fs.joinpath(mason_bin, binary_name .. ext)
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local package_path = M.get_package_path(package_name)
  if not package_path then
    return nil
  end

  if known_relative_path then
    local candidate = vim.fs.joinpath(package_path, known_relative_path)
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local matches = vim.fn.glob(vim.fs.joinpath(package_path, "**", binary_name), false, true)
  if #matches > 0 then
    return matches[1]
  end

  return nil
end

return M
