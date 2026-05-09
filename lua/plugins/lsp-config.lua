return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
        },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "bash-language-server",
                    "basedpyright",
                    "black",
                    "clang-format",
                    "clangd",
                    "codelldb",
                    "debugpy",
                    "isort",
                    "lua-language-server",
                    "powershell-editor-services",
                    "shellcheck",
                    "shfmt",
                    "stylua",
                },
                auto_update = false,
                run_on_start = true,
                start_delay = 3000,
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "basedpyright", "bashls", "clangd" },
                automatic_enable = false,
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
            local single_file_workspaces = {}
            local realtime_lsp_flags = {
                debounce_text_changes = 80,
            }
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

            local function mason_bin_executable(tool)
                if not is_windows then
                    return nil
                end

                local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
                for _, suffix in ipairs({ ".cmd", ".exe", ".bat", "" }) do
                    local candidate = vim.fs.joinpath(mason_bin, tool .. suffix)
                    if vim.fn.filereadable(candidate) == 1 then
                        return candidate
                    end
                end
            end

            local function mason_package_executable(package, pattern)
                local package_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", package)
                local matches = vim.fn.glob(vim.fs.joinpath(package_dir, pattern), false, true)
                return matches[1]
            end

            local function tool_path(tool, package, pattern)
                local mason_bin_path = mason_bin_executable(tool)
                if mason_bin_path then
                    return mason_bin_path
                end

                if is_windows then
                    local mason_path = mason_package_executable(package, pattern)
                    if mason_path and mason_path ~= "" then
                        return mason_path
                    end
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

                local home = normalize_path((vim.uv or vim.loop).os_homedir())
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

            vim.lsp.config.lua_ls = {
                cmd = { tool_path("lua-language-server", "lua-language-server", "bin/lua-language-server.exe") },
                filetypes = { "lua" },
                capabilities = capabilities,
                flags = realtime_lsp_flags,
                root_dir = function(bufnr, on_dir)
                    local fname = vim.api.nvim_buf_get_name(bufnr)
                    local util = require("lspconfig.util")
                    local found = util.root_pattern(
                        ".luarc.json",
                        ".luarc.jsonc",
                        ".stylua.toml",
                        "stylua.toml",
                        ".git"
                    )(fname)

                    on_dir(found or vim.fn.fnamemodify(fname, ":h"))
                end,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            }

            vim.lsp.config.basedpyright = {
                cmd = { tool_path("basedpyright-langserver", "basedpyright", "node_modules/.bin/basedpyright-langserver.cmd"), "--stdio" },
                filetypes = {"python"},
                capabilities = capabilities,
                flags = realtime_lsp_flags,
                root_markers = {},
                workspace_required = false,
                root_dir = function (bufnr, on_dir)
                    local fname = vim.api.nvim_buf_get_name(bufnr)
                    local util = require("lspconfig.util")
                    local project_root = util.root_pattern(
                        "pyrightconfig.json",
                        "basedpyrightconfig.json",
                        "pyproject.toml",
                        "setup.py",
                        "setup.cfg",
                        "tox.ini",
                        "requirements.txt"
                    )(fname)

                    if project_root then
                        on_dir(project_root)
                        return
                    end

                    local git_root = util.root_pattern(".git")(fname)
                    if git_root and not is_expensive_python_root(git_root) then
                        on_dir(git_root)
                        return
                    end

                    -- Single files such as C:\Users\david\wow.py should not make
                    -- basedpyright enumerate the whole user profile as a workspace.
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
            }

            vim.lsp.config.bashls = {
                cmd = { tool_path("bash-language-server", "bash-language-server", "node_modules/.bin/bash-language-server.cmd"), "start" },
                filetypes = { "sh", "bash" },
                root_markers = { ".git", ".shellcheckrc", "ShellCheckrc" },
                capabilities = capabilities,
                flags = realtime_lsp_flags,
                settings = {
                    bashIde = {
                        shellcheckPath = tool_path("shellcheck", "shellcheck", "shellcheck.exe"),
                        shfmt = {
                            path = tool_path("shfmt", "shfmt", "shfmt*.exe"),
                        },
                    },
                },
            }

            vim.lsp.config.clangd = {
                cmd = {
                    tool_path("clangd", "clangd", "clangd_*/bin/clangd.exe"),
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--fallback-style=llvm",
                },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                flags = realtime_lsp_flags,
                root_markers = {
                    "compile_commands.json",
                    "compile_flags.txt",
                    ".clangd",
                    ".git",
                    "CMakeLists.txt",
                    "Makefile",
                },
                capabilities = capabilities,
            }

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = { buffer = args.buf }

                    vim.diagnostic.enable(true, { bufnr = args.buf })

                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List references" }))
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
                    vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
                    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
                end,
            })

            vim.lsp.enable("lua_ls")
            vim.lsp.enable("basedpyright")
            vim.lsp.enable("bashls")
            vim.lsp.enable("clangd")
        end
    }
}
