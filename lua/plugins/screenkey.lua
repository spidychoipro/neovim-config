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
                local screenkey = require("screenkey")
                if screenkey.statusline_component_is_active() then
                    for index, key in ipairs(keys) do
                        if key.key == "%" then
                            keys[index].key = "%%"
                        end
                    end
                end

                return keys
            end,
        },
    },
}
