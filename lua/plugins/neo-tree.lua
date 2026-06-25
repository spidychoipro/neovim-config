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
          require("neo-tree.command").execute({
            source = "filesystem",
            position = "left",
            reveal = true,
          })
        end,
        desc = "Reveal file explorer",
      },
    },
    opts = {
      enable_diagnostics = true,
      enable_git_status = true,
      git_status_async = true,
      git_status_scope_to_path = true,
      git_status_async_options = {
        batch_size = 500,
        batch_delay = 20,
        max_lines = 5000,
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
