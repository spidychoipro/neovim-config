local M = {}
local runner = require("utils.runner")

local script_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "external-runner")

vim.fn.mkdir(script_dir, "p")
for _, f in ipairs(vim.fn.readdir(script_dir) or {}) do
  local full = vim.fs.joinpath(script_dir, f)
  local age = vim.uv.now() - ((vim.uv.fs_stat(full) or {}).mtime or {}).sec * 1000 or 0
  if age > 86400000 then
    pcall(vim.fn.delete, full)
  end
end

local function find_wt()
    if runner.executable("wt") then
        return "wt"
    end

    if runner.executable("wt.exe") then
        return "wt.exe"
    end

    return nil
end

local function windows_command(info)
    local file = runner.ps_quote(info.file)
    local output = runner.ps_quote(vim.fs.joinpath(info.dir, info.stem .. ".exe"))
    local venv_utils = require("utils.venv")

    if info.filetype == "python" then
        local python = venv_utils.resolve_python(info.dir)
        return "& " .. runner.ps_quote(python.path) .. " " .. file, python
    end

    if info.filetype == "lua" then
        local lua_cmd = runner.find_lua()
        if not lua_cmd then
            return nil, "lua or luajit was not found"
        end
        return "& " .. runner.ps_quote(lua_cmd) .. " " .. file
    end

    if info.filetype == "sh" or info.filetype == "bash" then
        local bash = runner.find_bash()
        if not bash then
            return nil, "bash was not found"
        end
        return "& " .. runner.ps_quote(bash) .. " " .. file
    end

    if info.filetype == "ps1" or info.filetype == "powershell" then
        return "& pwsh.exe -NoLogo -ExecutionPolicy Bypass -File " .. file
    end

    if info.filetype == "c" then
        return "& clang " .. file .. " -g -o " .. output .. "; if ($LASTEXITCODE -eq 0) { & " .. output .. " }"
    end

    if info.filetype == "cpp" then
        return "& clang++ " .. file .. " -g -o " .. output .. "; if ($LASTEXITCODE -eq 0) { & " .. output .. " }"
    end
end

local function linux_command(info)
    local file = runner.sh_quote(info.file)
    local output = runner.sh_quote(vim.fs.joinpath(info.dir, info.stem))
    local venv_utils = require("utils.venv")

    if info.filetype == "python" then
        local python = venv_utils.resolve_python()
        return runner.sh_quote(python.path) .. " " .. file, python
    end

    if info.filetype == "lua" then
        local lua_cmd = runner.find_lua()
        if not lua_cmd then
            return nil, "lua or luajit was not found"
        end
        return runner.sh_quote(lua_cmd) .. " " .. file
    end

    if info.filetype == "sh" or info.filetype == "bash" then
        local bash = runner.find_bash()
        if not bash then
            return nil, "bash was not found"
        end
        return runner.sh_quote(bash) .. " " .. file
    end

    if info.filetype == "ps1" or info.filetype == "powershell" then
        if not runner.executable("pwsh") then
            return nil, "pwsh was not found"
        end
        return "pwsh -NoLogo -NoProfile -File " .. file
    end

    if info.filetype == "c" then
        return "clang " .. file .. " -g -o " .. output .. " && " .. output
    end

    if info.filetype == "cpp" then
        return "clang++ " .. file .. " -g -o " .. output .. " && " .. output
    end
end

local function open_windows_terminal(info, command, python_info)
    if not runner.executable("pwsh.exe") then
        runner.notify("pwsh.exe was not found", vim.log.levels.ERROR)
        return
    end

    local script_id = tostring(vim.uv.hrtime())
    local runner_script = vim.fs.joinpath(script_dir, "run-" .. script_id .. ".ps1")

    local script_lines = {
        "$Host.UI.RawUI.WindowTitle = 'Run current file'",
        "Set-Location -LiteralPath " .. runner.ps_quote(info.dir),
        "$ErrorActionPreference = 'Continue'",
        "",
        command,
        "Write-Host ''",
        "Read-Host 'Press Enter to close'",
        "Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue",
        "exit",
    }

    if vim.fn.writefile(script_lines, runner_script) ~= 0 then
        runner.notify("Failed to create external runner script", vim.log.levels.ERROR)
        return
    end

    local wt = find_wt()
    local job_cmd

    if wt then
        job_cmd = {
            wt,
            "-w",
            "new",
            "pwsh.exe",
            "-NoLogo",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            runner_script,
        }
    else
        job_cmd = {
            "cmd.exe",
            "/d",
            "/c",
            "start",
            "pwsh.exe",
            "-NoLogo",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            runner_script,
        }
    end

    local success, job = pcall(vim.fn.jobstart, job_cmd, { detach = true })

    if not success or job <= 0 then
        pcall(vim.fn.delete, runner_script)

        if wt then
            local fallback_cmd = {
                "cmd.exe",
                "/d",
                "/c",
                "start",
                "pwsh.exe",
                "-NoLogo",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                runner_script,
            }
            local ok2, job2 = pcall(vim.fn.jobstart, fallback_cmd, { detach = true })
            if not ok2 or job2 <= 0 then
                pcall(vim.fn.delete, runner_script)
            end
        else
            runner.notify("Failed to open terminal", vim.log.levels.ERROR)
        end
    end
end

local function find_linux_shell()
    return "sh", "printf '\\nPress Enter to close...'; read -r _"
end

local function terminal_command(shell, script)
    local terminals = {
        { "x-terminal-emulator", "-e", shell, "-lc", script },
        { "gnome-terminal", "--", shell, "-lc", script },
        { "konsole", "-e", shell, "-lc", script },
        { "alacritty", "-e", shell, "-lc", script },
        { "kitty", shell, "-lc", script },
        { "wezterm", "start", "--", shell, "-lc", script },
        { "xterm", "-e", shell, "-lc", script },
    }

    for _, terminal in ipairs(terminals) do
        if runner.executable(terminal[1]) then
            return terminal
        end
    end
end

local function open_linux_terminal(info, command, python_info)
    if vim.env.TMUX then
        local shell, pause = find_linux_shell()
        local script = "cd " .. runner.sh_quote(info.dir)
            .. " && " .. command
            .. "; " .. pause
        local job = vim.fn.jobstart({ "tmux", "split-window", "-h", script }, { detach = true })
        if job > 0 then
            return
        end
    end

    local shell, pause = find_linux_shell()
    local script = "cd " .. runner.sh_quote(info.dir)
        .. " && " .. command
        .. "; " .. pause
    local terminal = terminal_command(shell, script)

    if not terminal then
        runner.notify("No supported external terminal was found", vim.log.levels.ERROR)
        return
    end

    local job = vim.fn.jobstart(terminal, { detach = true })
    if job <= 0 then
        runner.notify("Failed to open external terminal", vim.log.levels.ERROR)
    end
end

function M.run_current_file()
    if vim.bo.buftype == "" and vim.bo.modifiable and vim.bo.modified then
        vim.cmd("write")
    end

    local info = runner.file_info()
    if not info then
        return
    end

    local command, python_info, err
    if runner.is_windows then
        command, python_info = windows_command(info)
    else
        command, python_info = linux_command(info)
    end

    if not command then
        runner.notify(err or ("Unsupported filetype: " .. info.filetype), vim.log.levels.WARN)
        return
    end

    if runner.is_windows then
        open_windows_terminal(info, command, python_info)
    else
        open_linux_terminal(info, command, python_info)
    end
end

return M
