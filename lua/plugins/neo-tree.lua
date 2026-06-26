return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Neotree",
    keys = {
      {
        "<C-n>",
        function()
          if vim.bo.filetype == "neo-tree" then
            require("neo-tree.command").execute({ action = "close" })
          else
            require("neo-tree.command").execute({
              source = "filesystem",
              position = "left",
              reveal = true,
            })
          end
        end,
        desc = "Focus or close file explorer",
      },
    },
    opts = {
      close_if_last_window = true,
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            require("neo-tree").close_all()
          end,
        },
      },
      enable_diagnostics = true,
      enable_git_status = true,
      git_status_async = true,
      git_status_scope_to_path = true,
      git_status_async_options = {
        batch_size = 500,
        batch_delay = 20,
        max_lines = 5000,
      },
      window = {
        mappings = {
          ["<esc>"] = function()
            vim.cmd("wincmd p")
          end,
        },
      },
      indent_guides = {
        size = 1,
        follow = true,
      },
      filesystem = {
        async_directory_scan = "auto",
        scan_mode = "shallow",
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = false,
        filtered_items = {
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            ".cache",
            ".mypy_cache",
            ".pytest_cache",
            ".ruff_cache",
            ".venv",
            "__pycache__",
            "build",
            "cache",
            "dist",
            "env",
            "node_modules",
            "target",
            "tmp",
            "venv",
          },
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
  },
}
