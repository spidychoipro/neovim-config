local function python_formatter_command(ctx)
	local cache = vim.b[ctx.buf].python_formatter_interpreter
	if type(cache) == "table" and cache.filename == ctx.filename then
		return cache.path
	end

	local python = require("utils.venv").resolve_python(ctx.dirname)
	vim.b[ctx.buf].python_formatter_interpreter = {
		filename = ctx.filename,
		path = python.path,
	}

	return python.path
end

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
						lsp_format = "never",
					})
				end,
				desc = "Format file",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "python_isort", "python_black" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
			},
			formatters = {
				python_isort = {
					command = function(_, ctx)
						return python_formatter_command(ctx)
					end,
					args = function(_, ctx)
						return {
							"-m",
							"isort",
							"--profile",
							"black",
							"--stdout",
							"--line-ending",
							require("conform.util").buf_line_ending(ctx.buf),
							"--filename",
							"$FILENAME",
							"-",
						}
					end,
					cwd = function(_, ctx)
						return vim.fs.root(ctx.dirname, {
							".isort.cfg",
							"pyproject.toml",
							"setup.py",
							"setup.cfg",
							"tox.ini",
							".editorconfig",
						})
					end,
				},
				python_black = {
					command = function(_, ctx)
						return python_formatter_command(ctx)
					end,
					args = {
						"-m",
						"black",
						"--stdin-filename",
						"$FILENAME",
						"--quiet",
						"-",
					},
					cwd = function(_, ctx)
						return vim.fs.root(ctx.dirname, {
							"pyproject.toml",
						})
					end,
				},
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
