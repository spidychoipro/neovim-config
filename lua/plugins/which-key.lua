return {
    {
        "echasnovski/mini.icons",
        lazy = true,
    },
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
                { "<leader>'", desc = "Resume last picker" },
                { "<leader>J", desc = "Flash remote jump" },
                { "<leader>gt", desc = "Git status" },
                { "<leader>gc", desc = "Git commits" },
                { "<leader>gC", desc = "Git branches" },
                { "<leader>gS", desc = "Stage buffer" },
                { "<leader>gR", desc = "Reset buffer" },
                { "<leader>gB", desc = "Toggle line blame" },
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
