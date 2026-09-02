local M = {}
local platform = require("utils.platform")

local is_windows = platform.is_windows

-- Strict validation for venv
local function is_valid_venv(path)
    if not path or path == "" then
        return false
    end
    if vim.fn.isdirectory(path) ~= 1 then
        return false
    end

    local python_exe = platform.venv_python(path)

    return vim.fn.executable(python_exe) == 1
end

function M.find_venv(workspace)
    workspace = workspace or vim.fn.getcwd()

    -- ONLY use venv if we are in a "Project" (strong markers exist)
    -- This prevents accidental detection in home directory or simple script folders
    local markers = { ".git", "pyproject.toml", "requirements.txt", "setup.py", ".python-version" }
    local has_marker = false
    for _, marker in ipairs(markers) do
        if vim.fn.filereadable(vim.fs.joinpath(workspace, marker)) == 1
            or vim.fn.isdirectory(vim.fs.joinpath(workspace, marker)) == 1
        then
            has_marker = true
            break
        end
    end

    if not has_marker then
        return nil
    end

    local venv_names = { ".venv", "venv", "env" }
    for _, name in ipairs(venv_names) do
        local venv_path = vim.fs.joinpath(workspace, name)
        if is_valid_venv(venv_path) then
            return platform.venv_python(venv_path)
        end
    end

    return nil
end

function M.resolve_python(workspace)
    workspace = workspace or (vim.api.nvim_buf_get_name(0) ~= "" and vim.fs.dirname(vim.api.nvim_buf_get_name(0))) or vim.fn.getcwd()

    -- USER PRIORITY FOR WINDOWS: Single-file execution first
    if is_windows then
        -- 1. py launcher (Primary, most reliable for global packages)
        if vim.fn.executable("py") == 1 then
            return {
                path = "py",
                source = "global py launcher (primary)",
            }
        end

        -- 2. global python.exe
        if vim.fn.executable("python.exe") == 1 then
            return {
                path = "python.exe",
                source = "global python",
            }
        end
    end

    -- 3. venv (Only if strong project markers exist)
    local venv_path = M.find_venv(workspace)
    if venv_path then
        return {
            path = venv_path,
            source = "project venv",
        }
    end

    -- Default fallback
    local default = platform.python_cmd()
    return {
        path = default,
        source = "system default fallback",
    }
end

-- Compatibility layer for existing calls
function M.get_python_path(workspace)
    return M.resolve_python(workspace).path
end

return M
