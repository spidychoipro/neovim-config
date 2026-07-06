return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = "VeryLazy",
        build = ":TSUpdate",

        config = function()
            local treesitter = require("nvim-treesitter")
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
            local parsers = {
                "bash",
                "c",
                "cpp",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "powershell",
                "python",
                "query",
                "vim",
                "vimdoc",
            }

            treesitter.setup({
                highlight = {
                    enable = true,
                    max_file_lines = 5000,
                },
                incremental_selection = { enable = false },
                textobjects = { enable = false },
                indent = { enable = true },
            })

            vim.treesitter.language.register("bash", { "sh", "bash", "zsh" })
            vim.treesitter.language.register("powershell", { "ps1", "psm1", "psd1", "powershell" })
            vim.treesitter.language.register("vimdoc", { "help", "vimdoc" })

            local function is_plugin_manager_command()
                for _, arg in ipairs(vim.v.argv or {}) do
                    local value = tostring(arg)
                    if value:find("Lazy", 1, true) or value:find("TSUpdate", 1, true) or value:find("TSInstall", 1, true) then
                        return true
                    end
                end

                return false
            end

            local function get_available_parser_dirs()
                local dirs = {}

                -- nvim-treesitter installs parsers to the first user runtime dir
                local data_dir = vim.fn.stdpath("data")
                for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
                    if vim.startswith(p, data_dir) then
                        table.insert(dirs, vim.fs.joinpath(p, "parser"))
                        break
                    end
                end

                table.insert(dirs, vim.fs.joinpath(data_dir, "parser"))

                local prog = vim.v.progpath
                if prog then
                    local bundled = vim.fs.joinpath(vim.fs.dirname(prog), "..", "lib", "nvim", "parser")
                    table.insert(dirs, vim.fs.normalize(bundled))
                end

                return dirs
            end

            local function get_installed_parsers()
                local installed = {}
                for _, dir in ipairs(get_available_parser_dirs()) do
                    if vim.fn.isdirectory(dir) == 1 then
                        for _, file in ipairs(vim.fn.glob(vim.fs.joinpath(dir, "*.so"), false, true)) do
                            local name = vim.fn.fnamemodify(file, ":t:r")
                            installed[name] = true
                        end
                        for _, file in ipairs(vim.fn.glob(vim.fs.joinpath(dir, "*.dll"), false, true)) do
                            local name = vim.fn.fnamemodify(file, ":t:r")
                            installed[name] = true
                        end
                    end
                end
                return installed
            end

            local function ensure_missing_parsers()
                if vim.env.NVIM_SKIP_TS_AUTO_INSTALL == "1" or is_plugin_manager_command() then
                    return
                end

                local installed = get_installed_parsers()

                local missing = {}
                for _, parser in ipairs(parsers) do
                    if not installed[parser] then
                        table.insert(missing, parser)
                    end
                end

                if #missing == 0 then
                    return
                end

                local ok, install_module = pcall(require, "nvim-treesitter.install")
                if not ok then
                    return
                end

                if is_windows then
                    local function setup_msvc_env(vs_root)
                        local msvc_base = vim.fs.joinpath(vs_root, "VC", "Tools", "MSVC")
                        if vim.fn.isdirectory(msvc_base) ~= 1 then
                            return false
                        end

                        local msvc_versions = vim.fn.readdir(msvc_base)
                        if #msvc_versions == 0 then
                            return false
                        end

                        table.sort(msvc_versions, function(a, b) return a > b end)
                        local msvc_ver = msvc_versions[1]

                        local bin_x64 = vim.fs.joinpath(msvc_base, msvc_ver, "bin", "Hostx64", "x64")
                        if vim.fn.isdirectory(bin_x64) ~= 1 then
                            return false
                        end

                        if vim.fn.executable("cl.exe") == 1 then
                            return true
                        end

                        local sdk_root = "C:\\Program Files (x86)\\Windows Kits\\10"
                        local sdk_ver = ""
                        if vim.fn.isdirectory(sdk_root) == 1 then
                            local lib_dir = vim.fs.joinpath(sdk_root, "Lib")
                            if vim.fn.isdirectory(lib_dir) == 1 then
                                local versions = vim.fn.readdir(lib_dir)
                                table.sort(versions, function(a, b) return a > b end)
                                sdk_ver = versions[1] or ""
                            end
                        end

                        vim.env.PATH = bin_x64 .. ";" .. (vim.env.PATH or "")
                        vim.env.LIB = table.concat({
                            vim.fs.joinpath(msvc_base, msvc_ver, "lib", "x64"),
                            vim.fn.isdirectory(vim.fs.joinpath(sdk_root, "Lib", sdk_ver, "ucrt", "x64")) == 1 and vim.fs.joinpath(sdk_root, "Lib", sdk_ver, "ucrt", "x64") or nil,
                            vim.fn.isdirectory(vim.fs.joinpath(sdk_root, "Lib", sdk_ver, "um", "x64")) == 1 and vim.fs.joinpath(sdk_root, "Lib", sdk_ver, "um", "x64") or nil,
                        }, ";")
                        vim.env.INCLUDE = table.concat({
                            vim.fs.joinpath(msvc_base, msvc_ver, "include"),
                            vim.fn.isdirectory(vim.fs.joinpath(sdk_root, "Include", sdk_ver, "ucrt")) == 1 and vim.fs.joinpath(sdk_root, "Include", sdk_ver, "ucrt") or nil,
                            vim.fn.isdirectory(vim.fs.joinpath(sdk_root, "Include", sdk_ver, "um")) == 1 and vim.fs.joinpath(sdk_root, "Include", sdk_ver, "um") or nil,
                            vim.fn.isdirectory(vim.fs.joinpath(sdk_root, "Include", sdk_ver, "shared")) == 1 and vim.fs.joinpath(sdk_root, "Include", sdk_ver, "shared") or nil,
                        }, ";")

                        return true
                    end

                    local function find_msvc()
                        -- vswhere (most reliable)
                        if vim.fn.executable("vswhere.exe") == 1 then
                            local output = vim.fn.system({
                                "vswhere.exe", "-latest", "-products", "*",
                                "-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
                                "-property", "installationPath",
                            })
                            local vs_path = vim.fn.trim(output)
                            if vs_path ~= "" and vim.fn.isdirectory(vs_path) == 1 then
                                if setup_msvc_env(vs_path) then
                                    return true
                                end
                            end
                        end

                        -- Fallback: common VS installation paths
                        local vs_candidates = {}
                        for _, edition in ipairs({ "BuildTools", "Community", "Professional", "Enterprise" }) do
                            table.insert(vs_candidates, "C:\\Program Files\\Microsoft Visual Studio\\2022\\" .. edition)
                            table.insert(vs_candidates, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\" .. edition)
                            table.insert(vs_candidates, "C:\\Program Files\\Microsoft Visual Studio\\2019\\" .. edition)
                            table.insert(vs_candidates, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\" .. edition)
                            table.insert(vs_candidates, "C:\\Program Files\\Microsoft Visual Studio\\2017\\" .. edition)
                            table.insert(vs_candidates, "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\" .. edition)
                        end

                        for _, path in ipairs(vs_candidates) do
                            if vim.fn.isdirectory(path) == 1 and setup_msvc_env(path) then
                                return true
                            end
                        end

                        return false
                    end

                    if vim.fn.executable("cl.exe") ~= 1 and not find_msvc() then
                        vim.notify(
                            "MSVC not found. Treesitter will use system compiler (gcc/clang) if available.",
                            vim.log.levels.INFO,
                            { title = "nvim-treesitter" }
                        )
                    end
                end

                install_module.install(missing)
            end

            vim.schedule(ensure_missing_parsers)
        end,
    },
}
