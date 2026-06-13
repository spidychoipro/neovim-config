return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 200,
            spec = {
                { "<leader>c", group = "Code" },
                { "<leader>d", group = "Debug" },
                { "<leader>f", group = "Find" },
                { "<leader>g", group = "Format" },
                { "<leader>r", group = "Refactor" },
                { "<leader>s", group = "Session" },
                { "<leader>t", group = "Tasks" },
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
