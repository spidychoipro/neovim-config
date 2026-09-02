local M = {}

M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
M.is_mac = vim.fn.has("mac") == 1
M.is_linux = not M.is_windows and not M.is_mac
M.is_wsl = vim.env.WSL_DISTRO_NAME ~= nil or vim.env.WSL_INTEROP ~= nil

function M.path_sep()
  return M.is_windows and ";" or ":"
end

-- Executable file extensions tried for a bare binary name, in order.
-- On Windows Mason ships `.cmd`, `.exe`, `.bat` shims; elsewhere no extension.
M.exec_exts = M.is_windows and { ".cmd", ".exe", ".bat", "" } or { "" }

-- Path to the Python interpreter inside a virtualenv for this platform.
function M.venv_python(venv_path)
  if M.is_windows then
    return vim.fs.joinpath(venv_path, "Scripts", "python.exe")
  end
  return vim.fs.joinpath(venv_path, "bin", "python")
end

-- Path to `basedpyright-langserver` installed by Mason in its own venv.
function M.basedpyright_langserver(package_path)
  if M.is_windows then
    return vim.fs.joinpath(package_path, "venv", "Scripts", "basedpyright-langserver.exe")
  end
  return vim.fs.joinpath(package_path, "venv", "bin", "basedpyright-langserver")
end

function M.python_cmd()
  return M.is_windows and "python.exe" or "python"
end

function M.bash_exe()
  return M.is_windows and "bash.exe" or "bash"
end

return M
