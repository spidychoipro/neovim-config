return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "shfmt" },
					c = { "clang_format" },
					cpp = { "clang_format" },
				},
			})

			vim.keymap.set("n", "<leader>gf", function()
				require("conform").format({
					async = true,
					lsp_fallback = true,
				})
			end, { desc = "Format file" })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			local augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
			}

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
