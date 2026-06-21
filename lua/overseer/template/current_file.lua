local runner = require("utils.runner")

return {
    generator = function()
        local overseer = require("overseer")
        local info = runner.file_info()

        if not info then
            return {}
        end

        local filetype = info.filetype
        local dir = info.dir
        local name = info.name
        local stem = info.stem
        local file = info.file
        local templates = {}

        if filetype == "python" and vim.fn.executable("python") == 1 then
            table.insert(templates, {
                name = "Run current Python file",
                desc = "Run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    local venv_utils = require("utils.venv")
                    local python = venv_utils.get_python_path()
                    return {
                        cmd = { python, file },
                        cwd = dir,
                    }
                end,
            })
        end

        local lua_cmd = runner.find_lua()
        if filetype == "lua" and lua_cmd then
            table.insert(templates, {
                name = "Run current Lua file",
                desc = "Run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    return {
                        cmd = { lua_cmd, file },
                        cwd = dir,
                    }
                end,
            })
        end

        local bash_cmd = runner.find_bash()
        if (filetype == "sh" or filetype == "bash") and bash_cmd then
            table.insert(templates, {
                name = "Run current shell script",
                desc = "Run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    return {
                        cmd = { bash_cmd, file },
                        cwd = dir,
                    }
                end,
            })
        end

        local pwsh_cmd = runner.is_windows and "pwsh.exe" or "pwsh"
        if filetype == "ps1" and vim.fn.executable(pwsh_cmd) == 1 then
            table.insert(templates, {
                name = "Run current PowerShell script",
                desc = "Run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    return {
                        cmd = { pwsh_cmd, "-NoLogo", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", file },
                        cwd = dir,
                    }
                end,
            })
        end

        local c_output = vim.fs.joinpath(dir, stem .. (runner.is_windows and ".exe" or ""))
        if filetype == "c" and vim.fn.executable("clang") == 1 then
            table.insert(templates, {
                name = "Build current C file",
                desc = "Build " .. name,
                tags = { overseer.TAG.BUILD },
                builder = function()
                    return {
                        cmd = { "clang", file, "-g", "-o", c_output },
                        cwd = dir,
                        components = {
                            { "on_output_quickfix", open = true },
                            "default",
                        },
                    }
                end,
            })

            table.insert(templates, {
                name = "Build and run current C file",
                desc = "Build and run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    return {
                        name = "Build and run " .. name,
                        cwd = dir,
                        strategy = {
                            "orchestrator",
                            tasks = {
                                {
                                    name = "Build " .. name,
                                    cmd = { "clang", file, "-g", "-o", c_output },
                                    cwd = dir,
                                    strategy = { "jobstart", use_terminal = false },
                                    components = {
                                        { "on_output_quickfix", open = true },
                                        "default",
                                    },
                                },
                                {
                                    name = "Run " .. name,
                                    cmd = { c_output },
                                    cwd = dir,
                                    strategy = { "jobstart", use_terminal = false },
                                },
                            },
                        },
                        components = { "default" },
                    }
                end,
            })
        end

        local cpp_output = vim.fs.joinpath(dir, stem .. (runner.is_windows and ".exe" or ""))
        if filetype == "cpp" and vim.fn.executable("clang++") == 1 then
            table.insert(templates, {
                name = "Build current C++ file",
                desc = "Build " .. name,
                tags = { overseer.TAG.BUILD },
                builder = function()
                    return {
                        cmd = { "clang++", file, "-g", "-o", cpp_output },
                        cwd = dir,
                        components = {
                            { "on_output_quickfix", open = true },
                            "default",
                        },
                    }
                end,
            })

            table.insert(templates, {
                name = "Build and run current C++ file",
                desc = "Build and run " .. name,
                tags = { overseer.TAG.RUN },
                builder = function()
                    return {
                        name = "Build and run " .. name,
                        cwd = dir,
                        strategy = {
                            "orchestrator",
                            tasks = {
                                {
                                    name = "Build " .. name,
                                    cmd = { "clang++", file, "-g", "-o", cpp_output },
                                    cwd = dir,
                                    strategy = { "jobstart", use_terminal = false },
                                    components = {
                                        { "on_output_quickfix", open = true },
                                        "default",
                                    },
                                },
                                {
                                    name = "Run " .. name,
                                    cmd = { cpp_output },
                                    cwd = dir,
                                    strategy = { "jobstart", use_terminal = false },
                                },
                            },
                        },
                        components = { "default" },
                    }
                end,
            })
        end

        return templates
    end,
}
