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
            local Util = require("screenkey.util")
            local orig_validate = Util.validate
            Util.validate = function(spec, user_config, path)
                local keys = vim.tbl_keys(spec)
                table.sort(keys)

                for _, key in ipairs(keys) do
                    local s = spec[key]
                    local ok, err = pcall(vim.validate, key, s[1], s[2], s[3])
                    if not ok then
                        return false, string.format("%s: %s", path, err)
                    end
                end

                local errors = {}
                for k, _ in pairs(user_config) do
                    if not spec[k] then
                        table.insert(errors, ("'%s' is not a valid key of %s"):format(k, path))
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
