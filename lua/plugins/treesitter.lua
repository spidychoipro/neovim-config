return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            local treesitter = require("nvim-treesitter")
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

            local powershell_filetypes = {
                powershell = true,
                ps1 = true,
                psd1 = true,
                psm1 = true,
            }

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
                local dirs = { vim.fs.joinpath(vim.fn.stdpath("data"), "parser") }

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
                        for _, dll in ipairs(vim.fn.glob(vim.fs.joinpath(dir, "*.dll"), false, true)) do
                            local name = vim.fn.fnamemodify(dll, ":t:r")
                            installed[name] = true
                        end
                    end
                end
                return installed
            end

            local function has_c_compiler()
                if vim.fn.executable("cl.exe") == 1 then
                    return true
                end
                if vim.fn.executable("gcc") == 1 then
                    return true
                end
                if vim.fn.executable("cc") == 1 then
                    return true
                end
                return false
            end

            local function ensure_missing_parsers()
                if vim.env.NVIM_SKIP_TS_AUTO_INSTALL == "1" or is_plugin_manager_command() or not treesitter.get_installed then
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

                if not has_c_compiler() then
                    return
                end

                treesitter.install(missing)
            end

            vim.schedule(ensure_missing_parsers)

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true }),
                pattern = {
                    "bash",
                    "c",
                    "cpp",
                    "help",
                    "json",
                    "lua",
                    "markdown",
                    "powershell",
                    "ps1",
                    "psd1",
                    "psm1",
                    "python",
                    "query",
                    "sh",
                    "vim",
                    "vimdoc",
                    "zsh",
                },
                callback = function(args)
                    local ok = pcall(vim.treesitter.start, args.buf)
                    if ok then
                        if powershell_filetypes[vim.bo[args.buf].filetype] then
                            vim.bo[args.buf].syntax = ""
                        end

                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
