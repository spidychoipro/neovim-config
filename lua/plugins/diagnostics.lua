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
        texthl = {
            [severity.ERROR] = "DiagnosticSignError",
            [severity.WARN] = "DiagnosticSignWarn",
            [severity.INFO] = "DiagnosticSignInfo",
            [severity.HINT] = "DiagnosticSignHint",
        },
        numhl = {
            [severity.ERROR] = "DiagnosticSignError",
            [severity.WARN] = "DiagnosticSignWarn",
            [severity.INFO] = "DiagnosticSignInfo",
            [severity.HINT] = "DiagnosticSignHint",
        },
    },
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    float = {
        border = "rounded",
        focusable = false,
        source = "if_many",
        severity_sort = true,
    },
}

local function apply_diagnostic_config()
    -- Keep both the Neovim 0.11 signs table and legacy sign names in sync.
    vim.fn.sign_define("DiagnosticSignError", { text = "E", texthl = "DiagnosticSignError", numhl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = "W", texthl = "DiagnosticSignWarn", numhl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = "I", texthl = "DiagnosticSignInfo", numhl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "H", texthl = "DiagnosticSignHint", numhl = "DiagnosticSignHint" })

    vim.diagnostic.config(diagnostic_config)
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
                preset = "minimal",
                transparent_bg = true,
                transparent_cursorline = true,
                options = {
                    show_diags_only_under_cursor = false,
                    show_all_diags_on_cursorline = true,
                    enable_on_insert = false,
                    throttle = 20,
                    virt_texts = {
                        priority = 4096,
                    },
                    severity = {
                        severity.ERROR,
                        severity.WARN,
                        severity.INFO,
                        severity.HINT,
                    },
                    overwrite_events = { "LspAttach", "DiagnosticChanged", "BufEnter" },
                    override_open_float = true,
                },
            })

            apply_diagnostic_config()

            vim.schedule(function()
                tiny_diag.enable()
            end)

            vim.keymap.set("n", "<leader>e", function()
                vim.diagnostic.open_float()
            end, { desc = "Line Diagnostics" })

            vim.keymap.set("n", "<leader>ll", function()
                tiny_diag.toggle()
            end, { desc = "Toggle Inline Diagnostics" })
        end,
    },
}
