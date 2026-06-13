return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach", -- Or "VeryLazy"
        priority = 1000,
        config = function()
            require("tiny-inline-diagnostic").setup({
                preset = "modern", -- Options: "modern", "classic", "minimal", "powerline", "ghost", "amongus"
                options = {
                    -- Show diagnostics only on the current line
                    -- Set to false to show on all lines (more like VS Code Error Lens)
                    only_show_on_cursor = false,
                    -- Display diagnostics when in insert mode
                    show_in_insert = false,
                    -- Use a specific severity to show
                    severity = {
                        vim.diagnostic.severity.ERROR,
                        vim.diagnostic.severity.WARN,
                        vim.diagnostic.severity.INFO,
                        vim.diagnostic.severity.HINT,
                    },
                },
            })

            -- Configure native diagnostics
            vim.diagnostic.config({
                virtual_text = false, -- Disable default virtual text to avoid duplication
                underline = true,
                severity_sort = true,
                update_in_insert = false,
            })

            -- Quick error popup (fallback)
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics popup" })

            -- Toggle tiny-inline-diagnostic
            vim.keymap.set("n", "<leader>ll", function()
                local enabled = require("tiny-inline-diagnostic").get_status()
                if enabled then
                    require("tiny-inline-diagnostic").disable()
                    vim.notify("Tiny-inline-diagnostic disabled", vim.log.levels.INFO)
                else
                    require("tiny-inline-diagnostic").enable()
                    vim.notify("Tiny-inline-diagnostic enabled", vim.log.levels.INFO)
                end
            end, { desc = "Toggle fancy diagnostics" })
        end,
    },
}
