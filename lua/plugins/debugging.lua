return {
	{
		"nvim-neotest/nvim-nio",
		lazy = true,
	},
	{
		"mfussenegger/nvim-dap",
		keys = {
			{ "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<Leader>dc", function() require("dap").continue() end, desc = "Continue debug session" },
			{ "<Leader>di", function() require("dap").step_into() end, desc = "Step into" },
			{ "<Leader>do", function() require("dap").step_over() end, desc = "Step over" },
			{ "<Leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
			{ "<Leader>dx", function() require("dap").terminate() end, desc = "Terminate debug session" },
		},
		dependencies = {
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
			local mason_packages = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages")
			local debugpy_python = is_windows
				and vim.fs.joinpath(mason_packages, "debugpy", "venv", "Scripts", "python.exe")
				or vim.fs.joinpath(mason_packages, "debugpy", "venv", "bin", "python")
			local codelldb = is_windows
				and vim.fs.joinpath(mason_packages, "codelldb", "extension", "adapter", "codelldb.exe")
				or vim.fs.joinpath(mason_packages, "codelldb", "extension", "adapter", "codelldb")

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.25 },
							{ id = "breakpoints", size = 0.25 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						position = "left",
						size = 40,
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						position = "bottom",
						size = 10,
					},
				},
			})

			local venv_utils = require("utils.venv")

			if vim.fn.filereadable(debugpy_python) == 1 then
				local dap_python = require("dap-python")
				dap_python.setup(debugpy_python)
				dap_python.resolve_python = function()
					return venv_utils.get_python_path()
				end
			end

			if vim.fn.filereadable(codelldb) == 1 then
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = codelldb,
						args = { "--port", "${port}" },
					},
				}

				local function pick_executable()
					return coroutine.create(function(co)
						vim.ui.input({
							prompt = "Path to executable: ",
							default = vim.fn.getcwd() .. (is_windows and "\\" or "/"),
							completion = "file",
						}, function(input)
							coroutine.resume(co, input)
						end)
					end)
				end

				dap.configurations.c = {
					{
						name = "Launch file",
						type = "codelldb",
						request = "launch",
						program = pick_executable,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}
				dap.configurations.cpp = vim.deepcopy(dap.configurations.c)
			end

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
}
