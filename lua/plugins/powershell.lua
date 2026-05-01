return {
    {
        "TheLeoP/powershell.nvim",
        ft = "ps1",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
            local session_file = vim.fs.joinpath(vim.fn.stdpath("cache"), "powershell_es.session.json")

            vim.fn.delete(session_file)

            require("powershell").setup({
                bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services"),
                shell = is_windows and "pwsh.exe" or "pwsh",
                lsp_log_level = "Warning",
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })

            vim.schedule(function()
                if vim.bo.filetype == "ps1" then
                    require("powershell").initialize_or_attach(vim.api.nvim_get_current_buf())
                end
            end)
        end,
    },
}
