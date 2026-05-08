local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

local function current_file()
    if vim.bo.buftype ~= "" then
        return nil
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        return nil
    end

    return file
end

local function current_name(path)
    return vim.fs.basename(path)
end

local function current_dir(path)
    return vim.fs.dirname(path)
end

local function current_stem(path)
    local basename = current_name(path)
    return basename:match("^(.*)%.") or basename
end

local function find_bash()
    if vim.fn.executable("bash") == 1 then
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
    if vim.fn.executable("lua") == 1 then
        return "lua"
    end

    if vim.fn.executable("luajit") == 1 then
        return "luajit"
    end
end

return {
    generator = function()
        local overseer = require("overseer")
        local file = current_file()

        if not file then
            return {}
        end

        local filetype = vim.bo.filetype
        local dir = current_dir(file)
        local name = current_name(file)
        local stem = current_stem(file)
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

        local lua_cmd = find_lua()
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

        local bash_cmd = find_bash()
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

        local pwsh_cmd = is_windows and "pwsh.exe" or "pwsh"
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

        local c_output = vim.fs.joinpath(dir, stem .. (is_windows and ".exe" or ""))
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

        local cpp_output = vim.fs.joinpath(dir, stem .. (is_windows and ".exe" or ""))
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
