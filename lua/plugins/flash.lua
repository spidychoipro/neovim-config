return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>j",
                function()
                    require("flash").jump()
                end,
                mode = { "n", "x", "o" },
                desc = "Flash jump",
            },
        },
    },
}
