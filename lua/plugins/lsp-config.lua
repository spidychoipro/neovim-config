return {
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "basedpyright", "bashls" }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            
            -- Lua LSP 설정
            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                root_markers = { ".luarc.json", ".git" },
                filetypes = { "lua" },
                capabilities = capabilities
            } 

            -- Python LSP (basedpyright) 설정
            -- 💡 에러의 원인이었던 'root_dir' 함수를 제거했습니다.
            vim.lsp.config.basedpyright = {
                cmd = {"basedpyright-langserver", "--stdio"}, 
                root_markers = { "pyproject.toml", "setup.py", ".git" },
                filetypes = { "python" },
                capabilities = capabilities,
            }

            -- Bash LSP 설정
            vim.lsp.config.bashls = {
                cmd = { "bash-language-server", "start" },
                filetypes = { "sh", "bash" },
                root_markers = { ".git", "ShellCheckrc" },
                capabilities = capabilities
            }

            -- LSP 활성화 (사용자 방식 유지)
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("basedpyright")
            vim.lsp.enable("bashls")

            -- 키매핑 (사용자 방식 유지)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})
        end
    }
}
