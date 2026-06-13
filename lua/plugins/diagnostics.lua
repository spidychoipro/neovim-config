local severity = vim.diagnostic.severity

local diagnostic_signs = {
    [severity.ERROR] = "E",
    [severity.WARN] = "W",
    [severity.INFO] = "I",
    [severity.HINT] = "H",
}

local diagnostic_config = {
    virtual_text = false,
    virtual_lines = false,
    signs = {
        text = diagnostic_signs,
        numhl = {
            [severity.ERROR] = "DiagnosticSignError",
            [severity.WARN] = "DiagnosticSignWarn",
            [severity.INFO] = "DiagnosticSignInfo",
            [severity.HINT] = "DiagnosticSignHint",
        },
    },
    underline = true,
    severity_sort = true,
    update_in_insert = true,
    float = {
        border = "rounded",
        focusable = false,
        source = "if_many",
        severity_sort = true,
    },
}

local function apply_diagnostic_config()
    vim.diagnostic.config(diagnostic_config)
    vim.diagnostic.enable(true)
end

local function refresh_inline_diagnostics(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local function render()
        if not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end

        local ok_diag, tiny_diag = pcall(require, "tiny-inline-diagnostic")
        local ok_state, state = pcall(require, "tiny-inline-diagnostic.state")
        local ok_renderer, renderer = pcall(require, "tiny-inline-diagnostic.renderer")

        if ok_state then
            state.enable()
        end

        if ok_diag and ok_renderer and tiny_diag.config then
            renderer.safe_render(tiny_diag.config, bufnr)
        end
    end

    vim.schedule(render)
    vim.defer_fn(render, 20)
    vim.defer_fn(render, 120)
end

return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = { "LspAttach", "VeryLazy" },
        priority = 1000,
        init = apply_diagnostic_config,
        config = function()
            local tiny_diag = require("tiny-inline-diagnostic")

            tiny_diag.setup({
                preset = "modern",
                transparent_bg = false,
                transparent_cursorline = true,
                signs = {
                    arrow = "",
                    up_arrow = "",
                },
                options = {
                    show_diags_only_under_cursor = false,
                    show_all_diags_on_cursorline = true,
                    enable_on_insert = true,
                    throttle = 0,
                    multilines = {
                        enabled = true,
                        always_show = true,
                        trim_whitespaces = true,
                    },
                    virt_texts = {
                        priority = 4096,
                    },
                    severity = {
                        severity.ERROR,
                        severity.WARN,
                        severity.INFO,
                        severity.HINT,
                    },
                    overwrite_events = {
                        "LspAttach",
                        "DiagnosticChanged",
                        "BufEnter",
                        "TextChanged",
                        "TextChangedI",
                        "TextChangedP",
                    },
                    override_open_float = true,
                },
            })

            apply_diagnostic_config()

            local function enable_inline_diagnostics(bufnr)
                tiny_diag.enable()
                refresh_inline_diagnostics(bufnr)
            end

            local auto_enable = (vim.g.nvim_config or {}).features.auto_enable_inline_diagnostics

            vim.api.nvim_create_autocmd({
                "BufEnter",
                "DiagnosticChanged",
                "InsertEnter",
                "InsertLeave",
                "TextChanged",
                "TextChangedI",
                "TextChangedP",
            }, {
                group = vim.api.nvim_create_augroup("RealtimeInlineDiagnostics", { clear = true }),
                callback = function(args)
                    apply_diagnostic_config()
                    refresh_inline_diagnostics(args.buf)
                end,
            })

            if auto_enable then
                vim.schedule(function()
                    enable_inline_diagnostics()
                end)

                vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                    group = vim.api.nvim_create_augroup("AutoEnableInlineDiagnostics", { clear = true }),
                    callback = function(args)
                        enable_inline_diagnostics(args.buf)
                    end,
                })
            end

            vim.keymap.set("n", "<leader>e", function()
                vim.diagnostic.open_float()
            end, { desc = "Line Diagnostics" })

            vim.keymap.set("n", "<leader>ll", function()
                tiny_diag.toggle()
            end, { desc = "Toggle Inline Diagnostics" })

            vim.keymap.set("n", "<leader>ld", function()
                tiny_diag.disable()
            end, { desc = "Disable Inline Diagnostics Until Next File" })
        end,
    },
}
