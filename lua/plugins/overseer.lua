return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerOpen",
            "OverseerClose",
            "OverseerToggle",
            "OverseerRun",
            "OverseerTaskAction",
            "OverseerInfo",
            "OverseerClearCache",
        },
        keys = {
            {
                "<leader>tr",
                function()
                    if vim.bo.buftype == "" and vim.bo.modifiable and vim.bo.modified then
                        vim.cmd("write")
                    end
                    local overseer = require("overseer")
                    overseer.run_task({ tags = { overseer.TAG.RUN } })
                end,
                desc = "Run task",
            },
            {
                "<leader>tb",
                function()
                    if vim.bo.buftype == "" and vim.bo.modifiable and vim.bo.modified then
                        vim.cmd("write")
                    end
                    local overseer = require("overseer")
                    overseer.run_task({ tags = { overseer.TAG.BUILD } })
                end,
                desc = "Build task",
            },
            {
                "<leader>tt",
                function()
                    require("overseer").toggle({ enter = false })
                end,
                desc = "Toggle task list",
            },
            { "<leader>ta", "<cmd>OverseerTaskAction<CR>", desc = "Task action" },
        },
        config = function()
            local overseer = require("overseer")

            overseer.setup({
                dap = false,
                strategy = {
                    "jobstart",
                    use_terminal = false,
                },
                output = {
                    use_terminal = false,
                    preserve_output = false,
                },
                task_list = {
                    direction = "bottom",
                    min_height = 10,
                    max_height = { 16, 0.25 },
                    default_detail = 1,
                    bindings = {
                        ["<CR>"] = "ShowDetail",
                        ["q"] = "Close",
                    },
                },
                form = {
                    border = "rounded",
                },
                task_win = {
                    border = "rounded",
                },
                component_aliases = {
                    default = {
                        { "display_duration", detail_level = 2 },
                        "on_output_summarize",
                        "on_exit_set_status",
                        "on_complete_dispose",
                    },
                },
            })

            overseer.add_template_hook(nil, function(task_defn)
                task_defn.strategy = task_defn.strategy or { "jobstart", use_terminal = false }
            end)

            -- Fix Overseer Terminal Exit Issue: Press Enter to close task window
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "overseer",
                callback = function(args)
                    vim.keymap.set("n", "<CR>", function()
                        -- If we are in the task list, we want default behavior (ShowDetail)
                        -- But if we are in a task output/detail window, we want to close it.
                        local bufnr = args.buf
                        if vim.bo[bufnr].filetype == "overseer" then
                            -- Check if we are in the task list or a detail window
                            -- Overseer task list usually has a specific name or variable
                            if vim.api.nvim_buf_get_name(bufnr):match("Overseer") then
                                -- This is likely the task list
                                -- We'll let the default binding handle it if we can
                                -- But to be safe, if we are NOT in the task list, close window.
                                local win = vim.api.nvim_get_current_win()
                                local config = vim.api.nvim_win_get_config(win)
                                if config.relative ~= "" then
                                    -- It's a floating window (likely detail)
                                    vim.cmd("close")
                                else
                                    -- It's a split window
                                    -- If it's the bottom split, it might be the task list.
                                    -- For now, let's just use 'q' for closing and keep <CR> for detail.
                                    -- BUT the user wants Enter to close.
                                    vim.cmd("close")
                                end
                            end
                        end
                    end, { buffer = args.buf, silent = true })

                    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
                end,
            })
        end,
    },
}
