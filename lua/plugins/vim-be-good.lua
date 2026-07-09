return {
    {
        "ThePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        keys = {
            {
                "<leader>vg",
                function()
                    pcall(vim.cmd, "Neotree close")
                    vim.cmd("tabnew")
                    vim.cmd("VimBeGood")
                end,
                desc = "VimBeGood (isolated tab)",
            },
        },
    },
}
