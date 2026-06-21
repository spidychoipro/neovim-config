return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                char = {
                    enabled = false,
                },
            },
        },
        keys = {
            {
                "<leader>j",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash jump",
            },
            {
                "<leader>J",
                function()
                    require("flash").remote()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash remote jump",
            },
        },
    },
}
