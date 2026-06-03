local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local venv_names = { ".venv", "venv", "env" }
local python_project_markers = {
    "pyrightconfig.json",
    "basedpyrightconfig.json",
    "pyproject.toml",
    "requirements.txt",
    "setup.py",
    "setup.cfg",
    "tox.ini",
    ".python-version",
}

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

    if vim.fn.executable(python_exe) == 1 then
        return python_exe
    end

    return nil
end

local function normalize_path(path)
    if not path or path == "" then
        return nil
    end

    return vim.fs.normalize(path):gsub("[/\\]+$", "")
end

local function parent_dir(path)
    local parent = vim.fs.dirname(path)
    if not parent or parent == path then
        return nil
    end

    return parent
end

local function find_venv_in_dir(dir)
    for _, name in ipairs(venv_names) do
        local python = is_valid_venv(vim.fs.joinpath(dir, name))
        if python then
            return python
        end
    end

    return nil
end

local function find_python_project_root(start_dir)
    return vim.fs.root(start_dir, python_project_markers)
end

local function collect_search_dirs(start_dir, project_root)
    local dirs = {}
    local dir = normalize_path(start_dir)
    local root = normalize_path(project_root)

    while dir do
        table.insert(dirs, dir)

        if not root or dir == root then
            break
        end

        local parent = normalize_path(parent_dir(dir))
        if not parent then
            break
        end

        dir = parent
    end

    return dirs
end

function M.find_venv(workspace)
    workspace = normalize_path(workspace or vim.fn.getcwd())
    if not workspace then
        return nil
    end

    local project_root = find_python_project_root(workspace)
    for _, dir in ipairs(collect_search_dirs(workspace, project_root)) do
        local python = find_venv_in_dir(dir)
        if python then
            return python
        end
    end

    return nil
end

function M.resolve_python(workspace)
    workspace = workspace or (vim.api.nvim_buf_get_name(0) ~= "" and vim.fs.dirname(vim.api.nvim_buf_get_name(0))) or vim.fn.getcwd()

    local venv_path = M.find_venv(workspace)
    if venv_path then
        return {
            path = venv_path,
            source = "nearby local venv",
        }
    end

    if is_windows then
        if vim.fn.executable("py") == 1 then
            return {
                path = "py",
                source = "global py launcher",
            }
        end

        if vim.fn.executable("python.exe") == 1 then
            return {
                path = "python.exe",
                source = "global python",
            }
        end
    end

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
