return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach", -- Or "VeryLazy"
        priority = 1000,
        config = function()
            local normal_diagnostics = {
                virtual_text = false, -- Disable default virtual text to avoid duplication
                virtual_lines = false,
                signs = true,
                underline = true,
                severity_sort = true,
                update_in_insert = false,
            }

            require("tiny-inline-diagnostic").setup({
                preset = "minimal", -- Avoid heavy inline diagnostic background blocks
                transparent_bg = true,
                options = {
                    -- Show diagnostics only on the current line
                    -- Set to false to show on all lines (more like VS Code Error Lens)
                    show_diags_only_under_cursor = true,
                    -- Display diagnostics when in insert mode
                    enable_on_insert = false,
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
            vim.diagnostic.config(normal_diagnostics)

            local diagnostics_augroup = vim.api.nvim_create_augroup("NormalModeDiagnostics", { clear = true })

            vim.api.nvim_create_autocmd("InsertEnter", {
                group = diagnostics_augroup,
                callback = function()
                    vim.diagnostic.config(vim.tbl_extend("force", normal_diagnostics, {
                        signs = false,
                        underline = false,
                    }))

                    local ok, extmarks = pcall(require, "tiny-inline-diagnostic.extmarks")
                    if ok then
                        extmarks.clear(vim.api.nvim_get_current_buf())
                    end
                end,
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                group = diagnostics_augroup,
                callback = function()
                    vim.diagnostic.config(normal_diagnostics)

                    vim.schedule(function()
                        local ok_diag, diag = pcall(require, "tiny-inline-diagnostic")
                        local ok_renderer, renderer = pcall(require, "tiny-inline-diagnostic.renderer")
                        if ok_diag and ok_renderer and diag.config then
                            renderer.safe_render(diag.config, vim.api.nvim_get_current_buf())
                        end
                    end)
                end,
            })

            -- Quick error popup (fallback)
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics popup" })

            -- Toggle tiny-inline-diagnostic
            vim.keymap.set("n", "<leader>ll", function()
                require("tiny-inline-diagnostic").toggle()
            end, { desc = "Toggle inline diagnostics" })
        end,
    },
}
