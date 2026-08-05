return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
        },
        config = function()
            local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
            if vim.fn.isdirectory(mason_bin) == 1 then
                local path_sep = vim.loop.os_uname().sysname == "Windows_NT" and ";" or ":"
                vim.env.PATH = mason_bin .. path_sep .. vim.env.PATH
            end
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "bash-language-server",
                    "basedpyright",
                    "black",
                    "clang-format",
                    "clangd",
                    "codelldb",
                    "debugpy",
                    "isort",
                    "lua-language-server",
                    "powershell-editor-services",
                    "shellcheck",
                    "shfmt",
                    "stylua",
                    "tree-sitter-cli",
                },
                auto_update = false,
                run_on_start = false,
            })
        end,
    },
}
