return {
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
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

      require("auto-session").setup({
        auto_save = true,
        auto_restore = true,
        auto_restore_last_session = true,
        cwd_change_handling = true,
        suppressed_dirs = {
          vim.uv.os_homedir(),
        },
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
