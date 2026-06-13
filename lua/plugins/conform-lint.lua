return {
	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({
						async = true,
						lsp_fallback = true,
					})
				end,
				desc = "Format file",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local lint = require("lint")
			local augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
			}

			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			vim.schedule(function()
				lint.try_lint()
			end)
		end,
	},
}
