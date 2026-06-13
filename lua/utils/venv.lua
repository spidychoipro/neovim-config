local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

function M.get_python_path(workspace)
    workspace = workspace or vim.fn.getcwd()
    local venv_names = { ".venv", "venv", "env" }

    for _, name in ipairs(venv_names) do
        local venv_path = vim.fs.joinpath(workspace, name)
        if vim.fn.isdirectory(venv_path) == 1 then
            if is_windows then
                local python_exe = vim.fs.joinpath(venv_path, "Scripts", "python.exe")
                if vim.fn.executable(python_exe) == 1 then
                    return python_exe
                end
            else
                local python_exe = vim.fs.joinpath(venv_path, "bin", "python")
                if vim.fn.executable(python_exe) == 1 then
                    return python_exe
                end
            end
        end
    end

    return is_windows and "python.exe" or "python"
end

return M
