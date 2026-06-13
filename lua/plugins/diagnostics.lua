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
                    show_diags_only_under_cursor = false,
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
            local function render_inline_diagnostics()
                local bufnr = vim.api.nvim_get_current_buf()

                local function render()
                    if not vim.api.nvim_buf_is_valid(bufnr) or vim.fn.mode():find("i", 1, true) then
                        return
                    end

                    local ok_state, state = pcall(require, "tiny-inline-diagnostic.state")
                    if ok_state then
                        state.enable()
                    end

                    local ok_diag, diag = pcall(require, "tiny-inline-diagnostic")
                    local ok_renderer, renderer = pcall(require, "tiny-inline-diagnostic.renderer")
                    if ok_diag and ok_renderer and diag.config then
                        renderer.safe_render(diag.config, bufnr)
                    end
                end

                vim.schedule(render)
                vim.defer_fn(render, 80)
                vim.defer_fn(render, 200)
            end

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
                    render_inline_diagnostics()
                end,
            })

            vim.api.nvim_create_autocmd("DiagnosticChanged", {
                group = diagnostics_augroup,
                callback = function()
                    if not vim.fn.mode():find("i", 1, true) then
                        render_inline_diagnostics()
                    end
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
