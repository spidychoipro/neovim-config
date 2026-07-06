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
        scope = "line",
        severity_sort = true,
    },
}

local function apply_diagnostic_config()
    vim.diagnostic.config(diagnostic_config)
    vim.diagnostic.enable(true)
end

return {
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = { "BufReadPost", "BufNewFile", "LspAttach", "VeryLazy" },
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
                    throttle = 180,
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
                    },
                    overwrite_events = {
                        "LspAttach",
                        "BufReadPost",
                        "BufNewFile",
                        "BufWinEnter",
                        "DiagnosticChanged",
                        "BufEnter",
                        "CursorHold",
                        "CursorHoldI",
                        "InsertLeave",
                    },
                    override_open_float = true,
                },
            })

            local auto_enable = (vim.g.nvim_config or {}).features.auto_enable_inline_diagnostics

            if auto_enable then
                tiny_diag.enable()

                vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                    group = vim.api.nvim_create_augroup("AutoEnableInlineDiagnostics", { clear = true }),
                    callback = function()
                        tiny_diag.enable()
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
