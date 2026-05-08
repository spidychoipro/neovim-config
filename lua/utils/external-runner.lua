local M = {}

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

local function ps_quote(value)
    return "'" .. value:gsub("'", "''") .. "'"
end

local function sh_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Run current file" })
end

local function executable(name)
    return vim.fn.executable(name) == 1
end

local function find_bash()
    if executable("bash") then
        return "bash"
    end

    if is_windows then
        local git_bash = "C:\\Program Files\\Git\\bin\\bash.exe"
        if vim.fn.filereadable(git_bash) == 1 then
            return git_bash
        end
    end
end

local function find_lua()
    if executable("lua") then
        return "lua"
    end

    if executable("luajit") then
        return "luajit"
    end
end

local function find_wt()
    if executable("wt.exe") then
        return "wt.exe"
    end

    if executable("wt") then
        return "wt"
    end

    local windows_apps_wt = vim.fn.expand("$LOCALAPPDATA\\Microsoft\\WindowsApps\\wt.exe")
    if vim.fn.filereadable(windows_apps_wt) == 1 then
        return windows_apps_wt
    end
end

local function find_linux_shell()
    if executable("bash") then
        return "bash", "read -r -p 'Press Enter to close...' _"
    end

    return "sh", "printf 'Press Enter to close...'; read -r _"
end

local function file_info()
    if vim.bo.buftype ~= "" then
        notify("Cannot run this buffer type: " .. vim.bo.buftype, vim.log.levels.WARN)
        return nil
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        notify("No file is open", vim.log.levels.WARN)
        return nil
    end

    if vim.bo.modifiable and vim.bo.modified then
        vim.cmd("write")
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

local function windows_command(info)
    local file = ps_quote(info.file)
    local output = ps_quote(vim.fs.joinpath(info.dir, info.stem .. ".exe"))
    local venv_utils = require("utils.venv")

    if info.filetype == "python" then
        local python = venv_utils.get_python_path()
        return "& " .. ps_quote(python) .. " " .. file
    end

    if info.filetype == "lua" then
        local lua_cmd = find_lua()
        if not lua_cmd then
            return nil, "lua or luajit was not found"
        end
        return "& " .. ps_quote(lua_cmd) .. " " .. file
    end

    if info.filetype == "sh" or info.filetype == "bash" then
        local bash = find_bash()
        if not bash then
            return nil, "bash was not found"
        end
        return "& " .. ps_quote(bash) .. " " .. file
    end

    if info.filetype == "ps1" or info.filetype == "powershell" then
        return "& pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File " .. file
    end

    if info.filetype == "c" then
        return "& clang " .. file .. " -g -o " .. output .. "; if ($LASTEXITCODE -eq 0) { & " .. output .. " }"
    end

    if info.filetype == "cpp" then
        return "& clang++ " .. file .. " -g -o " .. output .. "; if ($LASTEXITCODE -eq 0) { & " .. output .. " }"
    end
end

local function linux_command(info)
    local file = sh_quote(info.file)
    local output = sh_quote(vim.fs.joinpath(info.dir, info.stem))
    local venv_utils = require("utils.venv")

    if info.filetype == "python" then
        local python = venv_utils.get_python_path()
        return sh_quote(python) .. " " .. file
    end

    if info.filetype == "lua" then
        local lua_cmd = find_lua()
        if not lua_cmd then
            return nil, "lua or luajit was not found"
        end
        return sh_quote(lua_cmd) .. " " .. file
    end

    if info.filetype == "sh" or info.filetype == "bash" then
        local bash = find_bash()
        if not bash then
            return nil, "bash was not found"
        end
        return sh_quote(bash) .. " " .. file
    end

    if info.filetype == "ps1" or info.filetype == "powershell" then
        if not executable("pwsh") then
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

local function open_windows_terminal(info, command)
    local wt = find_wt()
    if not wt then
        notify("Windows Terminal was not found", vim.log.levels.ERROR)
        return
    end

    if not executable("pwsh.exe") then
        notify("pwsh.exe was not found", vim.log.levels.ERROR)
        return
    end

    local script_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "external-runner")
    local script_id = tostring((vim.uv or vim.loop).hrtime())
    local runner_script = vim.fs.joinpath(script_dir, "run-" .. script_id .. ".ps1")
    local launcher_script = vim.fs.joinpath(script_dir, "launch-" .. script_id .. ".ps1")
    vim.fn.mkdir(script_dir, "p")

    local script =
        "$Host.UI.RawUI.WindowTitle = 'Run current file';"
        .. "Set-Location -LiteralPath " .. ps_quote(info.dir)
        .. "; try { "
        .. command
        .. " } catch { "
        .. "Write-Host $_"
        .. " } finally { "
        .. "Write-Host ''; Read-Host 'Press Enter to close'; exit"
        .. " }"

    local runner_lines = {
        script,
        "Remove-Item -LiteralPath " .. ps_quote(runner_script) .. " -Force -ErrorAction SilentlyContinue",
        "Remove-Item -LiteralPath " .. ps_quote(launcher_script) .. " -Force -ErrorAction SilentlyContinue",
    }

    local launcher_lines = {
        "$arguments = @(",
        "    '-w',",
        "    'new',",
        "    'pwsh.exe',",
        "    '-NoLogo',",
        "    '-NoProfile',",
        "    '-ExecutionPolicy',",
        "    'Bypass',",
        "    '-NoExit',",
        "    '-File',",
        "    " .. ps_quote(runner_script),
        ")",
        "Start-Process -FilePath " .. ps_quote(wt) .. " -ArgumentList $arguments",
        "Start-Sleep -Milliseconds 500",
        "Remove-Item -LiteralPath " .. ps_quote(launcher_script) .. " -Force -ErrorAction SilentlyContinue",
    }

    if vim.fn.writefile(runner_lines, runner_script) ~= 0
        or vim.fn.writefile(launcher_lines, launcher_script) ~= 0
    then
        notify("Failed to create external runner scripts", vim.log.levels.ERROR)
        return
    end

    local job = vim.fn.jobstart({
        "cmd.exe",
        "/d",
        "/c",
        "start",
        "",
        "pwsh.exe",
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        launcher_script,
    }, { detach = true })

    if job <= 0 then
        notify("Failed to open Windows Terminal", vim.log.levels.ERROR)
    end
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
        if executable(terminal[1]) then
            return terminal
        end
    end
end

local function open_linux_terminal(info, command)
    -- 1. Try tmux (Natural Job Control for Linux)
    if vim.env.TMUX then
        local shell, pause = find_linux_shell()
        local script = "cd " .. sh_quote(info.dir)
            .. " && " .. command
            .. "; printf '\\n'; " .. pause
        local job = vim.fn.jobstart({ "tmux", "split-window", "-h", script }, { detach = true })
        if job > 0 then
            return
        end
    end

    -- 2. Fallback to external GUI terminal
    local shell, pause = find_linux_shell()
    local script = "cd " .. sh_quote(info.dir)
        .. " && " .. command
        .. "; printf '\\n'; " .. pause
    local terminal = terminal_command(shell, script)

    if not terminal then
        notify("No supported external terminal was found", vim.log.levels.ERROR)
        return
    end

    local job = vim.fn.jobstart(terminal, { detach = true })
    if job <= 0 then
        notify("Failed to open external terminal", vim.log.levels.ERROR)
    end
end

function M.run_current_file()
    local info = file_info()
    if not info then
        return
    end

    local command, err
    if is_windows then
        command, err = windows_command(info)
    else
        command, err = linux_command(info)
    end

    if not command then
        notify(err or ("Unsupported filetype: " .. info.filetype), vim.log.levels.WARN)
        return
    end

    if is_windows then
        open_windows_terminal(info, command)
    else
        open_linux_terminal(info, command)
    end
end

return M
