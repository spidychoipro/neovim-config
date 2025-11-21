return {
    {
    "mason-org/mason.nvim",
    config = function()
	require("mason").setup()
    end,
    },
    {
	"mason-org/mason-lspconfig.nvim",
	config = function()
	require("mason-lspconfig").setup({
	    ensure_installed = { "lua_ls", "basedpyright", "bashls"}
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
		capabilities = capabilities
	    }

	    vim.lsp.config.basedpyright = {
                cmd = {"/usr/local/bin/basedpyright-langserver", "--stdio"},
                root_markers = { "pyproject.toml", "setup.py", ".git" },
                filetypes = { "python" },
		capabilities = capabilities
            }

	    vim.lsp.config.bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh", "bash" },
		root_markers = { ".git", "ShellCheckrc" },
		capabilities = capabilities
	    }

	    vim.lsp.enable("lua_ls")
	    vim.lsp.enable("basedpyright")
	    vim.lsp.enable("bashls")

	    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
	    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
	    vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})
	end
    }
}
