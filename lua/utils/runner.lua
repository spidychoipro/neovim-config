local M = {}

M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

function M.executable(name)
  return vim.fn.executable(name) == 1
end

function M.notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Run current file" })
end

function M.ps_quote(value)
  return "'" .. value:gsub("'", "''") .. "'"
end

function M.sh_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

function M.find_bash()
  if M.executable("bash") then
    return "bash"
  end

  if M.is_windows then
    local exe = vim.fn.exepath("bash")
    if exe ~= "" then
      return exe
    end

    local candidates = {
      "C:\\Program Files\\Git\\bin\\bash.exe",
      "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
      vim.fn.expand("~\\scoop\\apps\\git\\current\\bin\\bash.exe"),
    }
    for _, candidate in ipairs(candidates) do
      if vim.fn.filereadable(candidate) == 1 then
        return candidate
      end
    end
  end
end

function M.find_lua()
  if M.executable("lua") then
    return "lua"
  end

  if M.executable("luajit") then
    return "luajit"
  end
end

function M.file_info()
  if vim.bo.buftype ~= "" then
    M.notify("Cannot run this buffer type: " .. vim.bo.buftype, vim.log.levels.WARN)
    return nil
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    M.notify("No file is open", vim.log.levels.WARN)
    return nil
  end

  local dir = vim.fs.dirname(file)
  local name = vim.fs.basename(file)
  local stem = name:match("^(.*)%.") or name

  return {
    file = file,
    dir = dir,
    name = name,
    stem = stem,
    filetype = vim.bo.filetype,
  }
end

return M
