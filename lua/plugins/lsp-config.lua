return {
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
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
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "basedpyright", "bashls", "clangd" }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                root_markers = { ".luarc.json", ".git" },
                filetypes = { "lua" },
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            }

            vim.lsp.config.basedpyright = {
                cmd = {"basedpyright-langserver", "--stdio"}, 
                root_markers = { "pyproject.toml", "setup.py", ".git" },
                filetypes = { "python" },
                capabilities = capabilities,
            }

            vim.lsp.config.bashls = {
                cmd = { "bash-language-server", "start" },
                filetypes = { "sh", "bash" },
                root_markers = { ".git", ".shellcheckrc", "ShellCheckrc" },
                capabilities = capabilities
            }

            vim.lsp.config.clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
                capabilities = capabilities
            }

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = { buffer = args.buf }

                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "List references" }))
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
                    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
                end,
            })

            vim.lsp.enable("lua_ls")
            vim.lsp.enable("basedpyright")
            vim.lsp.enable("bashls")
            vim.lsp.enable("clangd")
        end
    }
}
