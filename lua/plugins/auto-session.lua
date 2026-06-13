return {
    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("auto-session").setup({
                auto_save = true,
                auto_restore = true,
                auto_restore_last_session = true,
                cwd_change_handling = true,
                close_unsupported_windows = true,
                args_allow_files_auto_save = true,
                git_use_branch_name = true,
                bypass_save_filetypes = { "alpha", "neo-tree" },
                session_lens = {
                    picker = "telescope",
                    load_on_setup = false,
                },
            })

            vim.keymap.set("n", "<leader>ss", "<cmd>AutoSession search<CR>", { desc = "Search sessions" })
            vim.keymap.set("n", "<leader>sr", "<cmd>AutoSession restore<CR>", { desc = "Restore session" })
            vim.keymap.set("n", "<leader>sw", "<cmd>AutoSession save<CR>", { desc = "Save session" })
            vim.keymap.set("n", "<leader>st", "<cmd>AutoSession toggle<CR>", { desc = "Toggle session autosave" })
        end,
    },
}
