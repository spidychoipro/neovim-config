return {
    {
        "gbprod/yanky.nvim",
        event = "VeryLazy",
        init = function()
            local group = vim.api.nvim_create_augroup("YankNotify", { clear = true })

            vim.api.nvim_create_autocmd("TextYankPost", {
                group = group,
                callback = function()
                    if vim.v.event.operator ~= "y" then
                        return
                    end

                    local ok, err = pcall(vim.notify, "Yanked", vim.log.levels.INFO, {
                        title = "Yank",
                    })

                    if not ok then
                        vim.api.nvim_err_writeln("Yank notification failed: " .. tostring(err))
                    end
                end,
            })
        end,
        opts = {
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 180,
            },
        },
        keys = {
            { "<leader>p", "<cmd>YankyRingHistory<CR>", mode = { "n", "x" }, desc = "Yank history" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Paste after cursor" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Paste before cursor" },
            { "[y", "<Plug>(YankyPreviousEntry)", mode = "n", desc = "Previous yank after paste" },
            { "]y", "<Plug>(YankyNextEntry)", mode = "n", desc = "Next yank after paste" },
        },
    },
}
