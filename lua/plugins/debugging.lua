return {
	{
		"nvim-neotest/nvim-nio",
	},
	{
		"mfussenegger/nvim-dap",
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

			dapui.setup()

			if vim.fn.filereadable(debugpy_python) == 1 then
				require("dap-python").setup(debugpy_python)
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

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
			vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Continue debug session" })
			vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "Step into" })
			vim.keymap.set("n", "<Leader>do", dap.step_over, { desc = "Step over" })
			vim.keymap.set("n", "<Leader>du", dap.step_out, { desc = "Step out" })
		end,
	},
}
