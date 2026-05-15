local slow_git_roots = {
  vim.uv.os_homedir(),
}

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  return vim.fs.normalize(path):gsub("[/\\]+$", ""):lower()
end

local function as_directory(path)
  local stat = path and vim.uv.fs_stat(path)
  if stat and stat.type == "file" then
    return vim.fs.dirname(path)
  end

  return path
end

local function is_slow_git_root(path)
  local start = as_directory(path or vim.uv.cwd())
  if not start then
    return false
  end

  local root = normalize_path(vim.fs.root(start, ".git"))
  if not root then
    return false
  end

  for _, slow_root in ipairs(slow_git_roots) do
    if root == normalize_path(slow_root) then
      return true
    end
  end

  return false
end

local function protect_large_roots()
  local ok, git = pcall(require, "neo-tree.git")
  if not ok or git._nvim_config_large_root_guard then
    return
  end

  local status = git.status
  local status_async = git.status_async
  local mark_gitignored = git.mark_gitignored

  git.status = function(path, ...)
    if is_slow_git_root(path) then
      return
    end

    return status(path, ...)
  end

  git.status_async = function(path, ...)
    if is_slow_git_root(path) then
      return
    end

    return status_async(path, ...)
  end

  git.mark_gitignored = function(state, ...)
    if state and is_slow_git_root(state.path) then
      return
    end

    return mark_gitignored(state, ...)
  end

  git._nvim_config_large_root_guard = true
end

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
      filesystem = {
        async_directory_scan = "auto",
        scan_mode = "shallow",
        bind_to_cwd = true,
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
      protect_large_roots()
      require("neo-tree").setup(opts)
    end,
  },
}
