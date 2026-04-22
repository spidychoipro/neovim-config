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
        config = function()
            local overseer = require("overseer")

            overseer.setup({
                dap = false,
                output = {
                    use_terminal = false,
                    preserve_output = false,
                },
                task_list = {
                    direction = "bottom",
                    min_height = 10,
                    max_height = { 16, 0.25 },
                    default_detail = 1,
                },
                form = {
                    border = "rounded",
                },
                task_win = {
                    border = "rounded",
                },
            })

            overseer.add_template_hook(nil, function(task_defn)
                if not task_defn.strategy then
                    task_defn.strategy = { "jobstart", use_terminal = false }
                end
            end)

            local function save_current_file()
                if vim.bo.buftype == "" and vim.bo.modifiable and vim.bo.modified then
                    vim.cmd("write")
                end
            end

            vim.keymap.set("n", "<leader>tr", function()
                save_current_file()
                overseer.run_task({ tags = { overseer.TAG.RUN } })
            end, { desc = "Run task" })

            vim.keymap.set("n", "<leader>tb", function()
                save_current_file()
                overseer.run_task({ tags = { overseer.TAG.BUILD } })
            end, { desc = "Build task" })

            vim.keymap.set("n", "<leader>tt", function()
                overseer.toggle({ enter = false })
            end, { desc = "Toggle task list" })

            vim.keymap.set("n", "<leader>ta", "<cmd>OverseerTaskAction<CR>", { desc = "Task action" })
        end,
    },
}
