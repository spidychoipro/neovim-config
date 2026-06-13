return {
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      local dashboard_state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "last-dashboard-state.json")

      local function normalize_path(path)
        return vim.fs.normalize(path):gsub("[/\\]+$", ""):lower()
      end

      local function current_cwd()
        return normalize_path(vim.fn.getcwd())
      end

      local function last_exit_was_dashboard()
        if vim.fn.filereadable(dashboard_state_file) == 0 then
          return false
        end

        local ok, lines = pcall(vim.fn.readfile, dashboard_state_file)
        if not ok or not lines[1] then
          return false
        end

        local decoded_ok, state = pcall(vim.json.decode, lines[1])
        return decoded_ok and state.dashboard == true and state.cwd == current_cwd()
      end

      local function remember_dashboard_state()
        local state = {
          cwd = current_cwd(),
          dashboard = vim.bo.filetype == "alpha",
        }

        pcall(vim.fn.mkdir, vim.fs.dirname(dashboard_state_file), "p")
        pcall(vim.fn.writefile, { vim.json.encode(state) }, dashboard_state_file)
      end

      local function is_neo_tree_buffer(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end

        local filetype = vim.bo[buf].filetype
        local name = vim.api.nvim_buf_get_name(buf)
        return filetype == "neo-tree" or name:match("^neo%-tree") ~= nil
      end

      local function close_neo_tree_session_buffers()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_neo_tree_buffer(buf) and #vim.api.nvim_list_wins() > 1 then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if is_neo_tree_buffer(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
      end

      local should_start_on_dashboard = last_exit_was_dashboard()

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = remember_dashboard_state,
      })

      require("auto-session").setup({
        auto_save = true,
        auto_restore = not should_start_on_dashboard,
        auto_restore_last_session = not should_start_on_dashboard,
        cwd_change_handling = true,
        close_unsupported_windows = true,
        args_allow_files_auto_save = true,
        git_use_branch_name = true,
        bypass_save_filetypes = { "alpha", "neo-tree" },
        pre_save_cmds = {
          close_neo_tree_session_buffers,
        },
        post_restore_cmds = {
          close_neo_tree_session_buffers,
        },
        session_lens = {
          picker = "telescope",
          load_on_setup = false,
        },
      })

      vim.keymap.set("n", "<leader>ss", "<cmd>AutoSession search<CR>", { desc = "Search sessions" })
      vim.keymap.set("n", "<leader>sr", "<cmd>AutoSession restore<CR>", { desc = "Restore session" })
      vim.keymap.set("n", "<leader>sw", "<cmd>AutoSession save<CR>", { desc = "Save session" })
      vim.keymap.set("n", "<leader>st", "<cmd>AutoSession toggle<CR>", { desc = "Toggle session autosave" })
    end,
  },
}
