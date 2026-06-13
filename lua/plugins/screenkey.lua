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
            local function patch_screenkey_validate()
                local ok, util = pcall(require, "screenkey.util")
                if not ok then
                    return
                end

                util.validate = function(spec, user_config, path)
                    local keys = vim.tbl_keys(spec)
                    table.sort(keys)

                    for _, key in ipairs(keys) do
                        local rule = spec[key]
                        local ok_validate, err = pcall(vim.validate, key, rule[1], rule[2], rule[3])
                        if not ok_validate then
                            return false, string.format("%s: %s", path, err)
                        end
                    end

                    local errors = {}
                    for key, _ in pairs(user_config) do
                        if not spec[key] then
                            table.insert(errors, string.format("'%s' is not a valid key of %s", key, path))
                        end
                    end

                    if #errors == 0 then
                        return true, nil
                    end

                    return false, table.concat(errors, "\n")
                end
            end

            patch_screenkey_validate()

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
