local function cleanup_stale_single_file_workspaces()
  local base = vim.fs.joinpath(vim.fn.stdpath("cache"), "basedpyright-single-file")
  if vim.fn.isdirectory(base) ~= 1 then
    return
  end

  local entries = vim.fn.readdir(base)
  local now = vim.uv.now()
  local max_age = 7 * 24 * 60 * 60 * 1000
  local max_entries = 200

  if #entries > max_entries then
    table.sort(entries, function(a, b)
      local stat_a = vim.uv.fs_stat(vim.fs.joinpath(base, a))
      local stat_b = vim.uv.fs_stat(vim.fs.joinpath(base, b))
      local mtime_a = stat_a and stat_a.mtime.sec or 0
      local mtime_b = stat_b and stat_b.mtime.sec or 0
      return mtime_a > mtime_b
    end)

    for i = max_entries + 1, #entries do
      vim.fn.delete(vim.fs.joinpath(base, entries[i]), "rf")
    end
  end

  for _, name in ipairs(vim.fn.readdir(base)) do
    local full = vim.fs.joinpath(base, name)
    local stat = vim.uv.fs_stat(full)
    if stat and stat.type == "directory" then
      local age = now - (stat.mtime.sec * 1000)
      if age > max_age then
        vim.fn.delete(full, "rf")
      end
    end
  end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local single_file_workspaces = {}
local python_analysis_exclude = {
  "**/.git",
  "**/.hg",
  "**/.svn",
  "**/.venv",
  "**/venv",
  "**/env",
  "**/.virtualenvs",
  "**/__pycache__",
  "**/.pytest_cache",
  "**/.mypy_cache",
  "**/.ruff_cache",
  "**/.cache",
  "**/cache",
  "**/tmp",
  "**/temp",
  "**/node_modules",
  "**/dist",
  "**/build",
  "**/target",
  "**/AppData/Local/nvim-data",
  "**/AppData/Local/Temp",
  "**/AppData/Roaming/npm-cache",
  "**/AppData/Roaming/Python",
}

local function tool_path(tool, package, search_pattern)
  local mason = require("utils.mason")
  local mason_bin_path = mason.find_bin_with_fallback(package, tool, search_pattern)
  if mason_bin_path then
    return mason_bin_path
  end

  local path = vim.fn.exepath(tool)
  return path ~= "" and path or tool
end

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  return vim.fs.normalize(path):lower():gsub("[/\\]+$", "")
end

local function is_expensive_python_root(path)
  local root = normalize_path(path)
  if not root then
    return true
  end

  local home = normalize_path(vim.uv.os_homedir())
  local appdata = normalize_path(os.getenv("APPDATA"))
  local localappdata = normalize_path(os.getenv("LOCALAPPDATA"))

  return root == home
    or root == appdata
    or root == localappdata
    or root:match("^%a:$") ~= nil
    or root:match("^%a:[/\\]program files") ~= nil
    or root:match("^%a:[/\\]windows") ~= nil
end

local function single_file_root(fname)
  local root = vim.fs.joinpath(
    vim.fn.stdpath("cache"),
    "basedpyright-single-file",
    vim.fn.sha256(vim.fs.normalize(fname)):sub(1, 16)
  )
  local dir = vim.fn.fnamemodify(fname, ":h")

  vim.fn.mkdir(root, "p")
  single_file_workspaces[root] = {
    file = vim.fs.normalize(fname),
    dir = vim.fs.normalize(dir),
  }

  return root
end

vim.lsp.config("lua_ls", {
  cmd = { tool_path("lua-language-server", "lua-language-server", "bin/lua-language-server.exe") },
  filetypes = { "lua" },
  capabilities = capabilities,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.root(bufnr, {
      ".luarc.json",
      ".luarc.jsonc",
      ".stylua.toml",
      "stylua.toml",
      ".git"
    })

    on_dir(found or vim.fn.fnamemodify(fname, ":h"))
  end,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

vim.lsp.config("basedpyright", {
  cmd = { tool_path("basedpyright-langserver", "basedpyright", "node_modules/.bin/basedpyright-langserver.cmd"), "--stdio" },
  filetypes = {"python"},
  capabilities = capabilities,
  root_markers = {},
  workspace_required = false,
  root_dir = function (bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local project_root = vim.fs.root(bufnr, {
      "pyrightconfig.json",
      "basedpyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "tox.ini",
      "requirements.txt"
    })

    if project_root then
      on_dir(project_root)
      return
    end

    local git_root = vim.fs.root(bufnr, ".git")
    if git_root and not is_expensive_python_root(git_root) then
      on_dir(git_root)
      return
    end

    on_dir(single_file_root(fname))
  end,
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        autoSearchPaths = false,
        fileEnumerationTimeout = 1,
        exclude = python_analysis_exclude,
      },
    },
  },
  before_init = function(_, config)
    local venv_utils = require("utils.venv")
    local python_path = venv_utils.get_python_path(config.root_dir)
    config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
      python = {
        pythonPath = python_path,
      },
    })

    local single_file = single_file_workspaces[config.root_dir]
    if single_file then
      config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
        basedpyright = {
          analysis = {
            include = { single_file.file },
            extraPaths = { single_file.dir },
          },
        },
      })
    end
  end,
})

vim.lsp.config("bashls", {
  cmd = { tool_path("bash-language-server", "bash-language-server", "node_modules/.bin/bash-language-server.cmd"), "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git", ".shellcheckrc", "ShellCheckrc" },
  capabilities = capabilities,
  settings = {
    bashIde = {
      shellcheckPath = tool_path("shellcheck", "shellcheck", "shellcheck.exe"),
      shfmt = {
        path = tool_path("shfmt", "shfmt", "shfmt*.exe"),
      },
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    tool_path("clangd", "clangd", "clangd_*/bin/clangd.exe"),
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".git",
    "CMakeLists.txt",
    "Makefile",
  },
  capabilities = capabilities,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.diagnostic.enable(true, { bufnr = args.buf })

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
    vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  end,
})

vim.schedule(function()
  cleanup_stale_single_file_workspaces()
end)

vim.lsp.enable("lua_ls")
vim.lsp.enable("basedpyright")
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
