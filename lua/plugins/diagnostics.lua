return {
    {
        "Maan2003/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()

            -- Configure native diagnostics
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    spacing = 4,
                },
                underline = true,
                severity_sort = true,
                update_in_insert = false,
                -- Initially disable lsp_lines (multiline) to use virtual_text
                virtual_lines = false,
            })

            -- Toggle lsp_lines
            vim.keymap.set("n", "<leader>ll", function()
                local config = vim.diagnostic.config()
                local new_virtual_lines = not config.virtual_lines
                vim.diagnostic.config({
                    virtual_lines = new_virtual_lines,
                    virtual_text = not new_virtual_lines and {
                        prefix = "●",
                        spacing = 4,
                    } or false,
                })
            end, { desc = "Toggle lsp_lines" })

            -- Quick error popup
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics popup" })
        end,
    },
}
