return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        cmd = "Neotree",
        keys = {
            { "<C-n>", "<cmd>Neotree filesystem reveal left<CR>", desc = "Reveal file explorer" },
        },
    },
}
