local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- Strict validation for venv
local function is_valid_venv(path)
    if not path or path == "" then
        return false
    end
    if vim.fn.isdirectory(path) ~= 1 then
        return false
    end

    local python_exe
    if is_windows then
        python_exe = vim.fs.joinpath(path, "Scripts", "python.exe")
    else
        python_exe = vim.fs.joinpath(path, "bin", "python")
    end

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
            if is_windows then
                return vim.fs.joinpath(venv_path, "Scripts", "python.exe")
            else
                return vim.fs.joinpath(venv_path, "bin", "python")
            end
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
    local default = is_windows and "python.exe" or "python"
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
