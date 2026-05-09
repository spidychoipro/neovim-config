return {
    {
        "TheLeoP/powershell.nvim",
        ft = "ps1",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
            local session_file = vim.fs.joinpath(vim.fn.stdpath("cache"), "powershell_es.session.json")
            local shell = is_windows and vim.fn.exepath("pwsh.exe") or vim.fn.exepath("pwsh")
            local powershell_term_jobs = {}
            local group = vim.api.nvim_create_augroup("UserPowerShellEditorServices", { clear = true })

            local function track_term_job(args)
                local data = args.data or {}
                local bufnr = data.buf
                local channel = data.channel

                if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
                    return
                end

                powershell_term_jobs[bufnr] = channel
                vim.bo[bufnr].buflisted = false
                vim.bo[bufnr].bufhidden = "hide"

                vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout" }, {
                    group = group,
                    buffer = bufnr,
                    callback = function()
                        powershell_term_jobs[bufnr] = nil
                    end,
                })
            end

            local function stop_powershell_jobs()
                local ok_util, util = pcall(require, "powershell.util")
                if ok_util then
                    for _, term in pairs(util.terms or {}) do
                        if term.buf and term.channel then
                            powershell_term_jobs[term.buf] = term.channel
                        end
                    end
                end

                for _, client in ipairs(vim.lsp.get_clients({ name = "powershell_es" })) do
                    pcall(function()
                        client:stop(true)
                    end)
                end

                for bufnr, channel in pairs(powershell_term_jobs) do
                    if type(channel) == "number" and channel > 0 then
                        pcall(vim.fn.jobstop, channel)
                    end

                    if vim.api.nvim_buf_is_valid(bufnr) then
                        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
                    end

                    powershell_term_jobs[bufnr] = nil
                end
            end

            vim.fn.delete(session_file)

            require("powershell").setup({
                bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services"),
                shell = shell ~= "" and shell or (is_windows and "pwsh.exe" or "pwsh"),
                lsp_log_level = "Warning",
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })

            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "powershell.nvim-term",
                callback = track_term_job,
                desc = "Track the hidden PowerShell Editor Services terminal job.",
            })

            vim.api.nvim_create_autocmd({ "ExitPre", "VimLeavePre" }, {
                group = group,
                callback = stop_powershell_jobs,
                desc = "Stop hidden PowerShell Editor Services jobs before quitting.",
            })

            vim.schedule(function()
                if #vim.api.nvim_list_uis() > 0 and vim.bo.filetype == "ps1" then
                    require("powershell").initialize_or_attach(vim.api.nvim_get_current_buf())
                end
            end)
        end,
    },
}
