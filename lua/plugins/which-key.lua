return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 200,
            spec = {
                { "<leader>d", group = "Debug" },
                { "<leader>g", group = "Git" },
                { "<leader>l", group = "LSP" },
                { "<leader>s", group = "Session" },
                { "<leader>t", group = "Tasks" },
                { "<leader>u", group = "UI" },
                { "<leader>x", group = "Trouble" },
                { "<leader>c", group = "Symbols" },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer local keymaps",
            },
        },
    },
}
