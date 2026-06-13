return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 200,
            spec = {
                { "<leader>d", group = "Debug" },
                { "<leader>l", group = "LSP" },
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
