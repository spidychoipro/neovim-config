return {
    {
        "NStefan002/screenkey.nvim",
        lazy = false,
        version = "*",
        keys = {
            { "<leader>uk", "<cmd>Screenkey toggle<cr>", desc = "Toggle Screenkey" },
            { "<leader>uK", "<cmd>Screenkey redraw<cr>", desc = "Redraw Screenkey" },
        },
        opts = {
            win_opts = {
                border = "single",
                title = "Screenkey",
                title_pos = "center",
            },
            compress_after = 3,
            clear_after = 3,
            show_leader = true,
            group_mappings = true,
            disable = {
                filetypes = {},
                buftypes = { "terminal" },
                events = false,
            },
            filter = function(keys)
                if vim.g.screenkey_statusline_component then
                    for index, key in ipairs(keys) do
                        if key.key == "%" then
                            keys[index].key = "%%"
                        end
                    end
                end

                return keys
            end,
        },
        config = function(_, opts)
            local screenkey = require("screenkey")
            screenkey.setup(opts)

            local function enable_screenkey()
                if not screenkey.is_active() then
                    screenkey.toggle()
                end
            end

            vim.keymap.set("n", "<leader>uo", function()
                if screenkey.is_active() then
                    screenkey.toggle()
                end
            end, { desc = "Disable Screenkey Until Next File" })

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                group = vim.api.nvim_create_augroup("AutoEnableScreenkey", { clear = true }),
                callback = enable_screenkey,
            })

            vim.schedule(function()
                enable_screenkey()
            end)
        end,
    },
}
