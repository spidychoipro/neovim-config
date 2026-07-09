return {
    {
        "ThePrimeagen/vim-be-good",
        cmd = "VimBeGood",
        init = function()
            vim.g.vim_be_good_window_padding_row = 0
            vim.g.vim_be_good_window_padding_col = 0
        end,
        keys = {
            {
                "<leader>vg",
                function()
                    pcall(vim.cmd, "Neotree close")
                    vim.cmd("tabnew")
                    vim.cmd("only")
                    vim.cmd("VimBeGood")
                end,
                desc = "VimBeGood",
            },
        },
    },
}
