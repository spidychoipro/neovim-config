return {
    {
        "TheLeoP/powershell.nvim",
        ft = "ps1",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

            require("powershell").setup({
                bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services"),
                shell = is_windows and "pwsh.exe" or "pwsh",
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
        end,
    },
}
