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

    -- Do not automatically pick up venvs in HOME directory unless there are project markers
    local home = vim.fn.expand("$HOME")
    if workspace == home then
        local markers = { ".git", "pyproject.toml", "setup.py", "requirements.txt", ".python-version" }
        local found_marker = false
        for _, marker in ipairs(markers) do
            if vim.fn.filereadable(vim.fs.joinpath(workspace, marker)) == 1
                or vim.fn.isdirectory(vim.fs.joinpath(workspace, marker)) == 1
            then
                found_marker = true
                break
            end
        end
        if not found_marker then
            return nil
        end
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
    local venv = M.find_venv(workspace)
    if venv then
        return {
            path = venv,
            source = "project venv",
        }
    end

    if is_windows then
        if vim.fn.executable("py") == 1 then
            return {
                path = "py",
                source = "global py",
            }
        end
        return {
            path = "python.exe",
            source = "global python",
        }
    end

    return {
        path = "python",
        source = "global python",
    }
end

-- Compatibility layer for existing calls
function M.get_python_path(workspace)
    return M.resolve_python(workspace).path
end

return M
