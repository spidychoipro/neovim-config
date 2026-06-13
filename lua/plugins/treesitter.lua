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

            treesitter.setup()

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

            local function ensure_missing_parsers()
                if vim.env.NVIM_SKIP_TS_AUTO_INSTALL == "1" or is_plugin_manager_command() or not treesitter.get_installed then
                    return
                end

                local installed = {}
                for _, parser in ipairs(treesitter.get_installed("parsers")) do
                    installed[parser] = true
                end

                local missing = {}
                for _, parser in ipairs(parsers) do
                    if not installed[parser] then
                        table.insert(missing, parser)
                    end
                end

                if #missing > 0 then
                    treesitter.install(missing)
                end
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
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
