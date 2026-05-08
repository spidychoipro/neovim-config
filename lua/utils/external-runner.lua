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
    if executable("wt") then
        return "wt"
    end

    if executable("wt.exe") then
        return "wt.exe"
    end

    return nil
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
        local python = venv_utils.resolve_python()
        -- Pass both path and source to the runner script via environment variables or direct injection
        -- For simplicity, we'll inject them into the command string or use them in the runner script
        return "& " .. ps_quote(python.path) .. " " .. file, python
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
    local file = sh_quote(info.file)
    local output = sh_quote(vim.fs.joinpath(info.dir, info.stem))
    local venv_utils = require("utils.venv")

    if info.filetype == "python" then
        local python = venv_utils.resolve_python()
        return sh_quote(python.path) .. " " .. file, python
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

local function open_windows_terminal(info, command, python_info)
    if not executable("pwsh.exe") then
        notify("pwsh.exe was not found", vim.log.levels.ERROR)
        return
    end

    local script_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "external-runner")
    local script_id = tostring((vim.uv or vim.loop).hrtime())
    local runner_script = vim.fs.joinpath(script_dir, "run-" .. script_id .. ".ps1")
    vim.fn.mkdir(script_dir, "p")

    -- Robust PowerShell runner script
    local script_lines = {
        "$Host.UI.RawUI.WindowTitle = 'Run current file'",
        "Set-Location -LiteralPath " .. ps_quote(info.dir),
        "$ErrorActionPreference = 'Continue'",
        "",
    }

    if info.filetype == "python" and python_info then
        table.insert(script_lines, "Write-Host '--- Python Environment ---'")
        table.insert(script_lines, "Write-Host 'Interpreter: " .. python_info.path .. "'")
        table.insert(script_lines, "Write-Host 'Source:      " .. python_info.source .. "'")
        table.insert(script_lines, "Write-Host '--------------------------'")
        table.insert(script_lines, "Write-Host ''")
    end

    table.insert(script_lines, command)
    table.insert(script_lines, "if ($LASTEXITCODE -ne 0 -or $? -eq $false) {")
    table.insert(script_lines, "    Write-Host ''")
    table.insert(script_lines, "    Read-Host 'Press Enter to close'")
    table.insert(script_lines, "}")
    table.insert(script_lines, "Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue")
    table.insert(script_lines, "exit")

    if vim.fn.writefile(script_lines, runner_script) ~= 0 then
        notify("Failed to create external runner script", vim.log.levels.ERROR)
        return
    end

    local wt = find_wt()
    local job_cmd

    if wt then
        -- Prefer launching via Windows Terminal if found in PATH
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
        -- Fallback to standard 'start' command which opens the default terminal (usually WT or ConHost)
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

    -- Use pcall to prevent E5108 and E475 from crashing the session
    local success, job = pcall(vim.fn.jobstart, job_cmd, { detach = true })

    if not success or job <= 0 then
        -- Last ditch attempt if direct 'wt' launch failed (e.g. if it was a Store alias that jobstart hates)
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
            pcall(vim.fn.jobstart, fallback_cmd, { detach = true })
        else
            notify("Failed to open terminal", vim.log.levels.ERROR)
        end
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

local function open_linux_terminal(info, command, python_info)
    -- 1. Try tmux (Natural Job Control for Linux)
    if vim.env.TMUX then
        local shell, pause = find_linux_shell()
        local script = "cd " .. sh_quote(info.dir)
        if info.filetype == "python" and python_info then
            script = script .. " && echo '--- Python Environment ---'"
            script = script .. " && echo 'Interpreter: " .. python_info.path .. "'"
            script = script .. " && echo 'Source:      " .. python_info.source .. "'"
            script = script .. " && echo '--------------------------' && echo ''"
        end
        script = script .. " && " .. command
            .. "; printf '\\n'; " .. pause
        local job = vim.fn.jobstart({ "tmux", "split-window", "-h", script }, { detach = true })
        if job > 0 then
            return
        end
    end

    -- 2. Fallback to external GUI terminal
    local shell, pause = find_linux_shell()
    local script = "cd " .. sh_quote(info.dir)
    if info.filetype == "python" and python_info then
        script = script .. " && echo '--- Python Environment ---'"
        script = script .. " && echo 'Interpreter: " .. python_info.path .. "'"
        script = script .. " && echo 'Source:      " .. python_info.source .. "'"
        script = script .. " && echo '--------------------------' && echo ''"
    end
    script = script .. " && " .. command
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

    local command, python_info, err
    if is_windows then
        command, python_info = windows_command(info)
    else
        command, python_info = linux_command(info)
    end

    if not command then
        notify(err or ("Unsupported filetype: " .. info.filetype), vim.log.levels.WARN)
        return
    end

    if is_windows then
        open_windows_terminal(info, command, python_info)
    else
        open_linux_terminal(info, command, python_info)
    end
end

return M
