return {
    {
        "gbprod/yanky.nvim",
        event = "VeryLazy",
        init = function()
            local group = vim.api.nvim_create_augroup("YankNotify", { clear = true })
            local notice = { buf = nil, win = nil }

            local function close_notice()
                if notice.win and vim.api.nvim_win_is_valid(notice.win) then
                    vim.api.nvim_win_close(notice.win, true)
                end

                notice.win = nil
                notice.buf = nil
            end

            local function show_yank_notice()
                close_notice()

                local text = " Copied "
                local width = #text
                local ui = vim.api.nvim_list_uis()[1] or {}
                local editor_width = ui.width or vim.o.columns
                local editor_height = ui.height or vim.o.lines
                local row = math.max(editor_height - 5, 0)
                local col = math.max(math.floor((editor_width - width) / 2), 0)

                vim.api.nvim_set_hl(0, "YankNotifyNormal", {
                    bg = "#44475a",
                    bold = true,
                    fg = "#f8f8f2",
                })
                vim.api.nvim_set_hl(0, "YankNotifyBorder", {
                    bg = "#44475a",
                    fg = "#bd93f9",
                })

                notice.buf = vim.api.nvim_create_buf(false, true)
                vim.bo[notice.buf].bufhidden = "wipe"
                vim.api.nvim_buf_set_lines(notice.buf, 0, -1, false, { text })

                notice.win = vim.api.nvim_open_win(notice.buf, false, {
                    relative = "editor",
                    row = row,
                    col = col,
                    width = width,
                    height = 1,
                    style = "minimal",
                    border = "rounded",
                    focusable = false,
                    zindex = 250,
                })

                vim.wo[notice.win].winblend = 0
                vim.wo[notice.win].winhighlight = "Normal:YankNotifyNormal,FloatBorder:YankNotifyBorder"

                local fade_steps = { 15, 30, 45, 60, 75, 90 }

                for index, blend in ipairs(fade_steps) do
                    vim.defer_fn(function()
                        if notice.win and vim.api.nvim_win_is_valid(notice.win) then
                            vim.wo[notice.win].winblend = blend
                        end
                    end, 450 + (index * 90))
                end

                vim.defer_fn(close_notice, 1100)
            end

            vim.api.nvim_create_autocmd("TextYankPost", {
                group = group,
                callback = function()
                    if vim.v.event.operator ~= "y" then
                        return
                    end

                    vim.schedule(function()
                        local ok, err = pcall(show_yank_notice)

                        if not ok then
                            vim.api.nvim_err_writeln("Yank notification failed: " .. tostring(err))
                        end
                    end)
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
