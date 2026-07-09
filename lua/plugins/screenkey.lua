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
            local util = require("screenkey.util")
            util.validate = function(specs, user_config, path)
                local errors = {}
                for key, spec in pairs(specs) do
                    local ok, err = pcall(vim.validate, key, spec[1], spec[2], spec[3])
                    if not ok then
                        table.insert(errors, string.format("%s: %s", path, err))
                    end
                end
                for key in pairs(user_config) do
                    if not specs[key] then
                        table.insert(errors, string.format("'%s' is not a valid key of %s", key, path))
                    end
                end
                if #errors == 0 then
                    return true, nil
                end
                return false, table.concat(errors, "\n")
            end

            local screenkey = require("screenkey")
            screenkey.setup(opts)

            local function enable_screenkey()
                if not screenkey.is_active() then
                    screenkey.toggle()
                end
            end
            local auto_enable = (vim.g.nvim_config or {}).features.auto_enable_screenkey

            vim.keymap.set("n", "<leader>uo", function()
                if screenkey.is_active() then
                    screenkey.toggle()
                end
            end, { desc = "Disable Screenkey Until Next File" })

            if auto_enable then
                vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
                    group = vim.api.nvim_create_augroup("AutoEnableScreenkey", { clear = true }),
                    callback = enable_screenkey,
                })

                vim.schedule(function()
                    enable_screenkey()
                end)
            end
        end,
    },
}
