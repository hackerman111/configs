return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
			"mfussenegger/nvim-dap-python",
		},

		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local mason_dap = require("mason-nvim-dap")
			local dap_virtual_text = require("nvim-dap-virtual-text")
			local resolve_python = require("config.python").resolve_python

			dap_virtual_text.setup()

			mason_dap.setup({
				ensure_installed = { "codelldb", "python" },
				automatic_installation = true,
				handlers = {
					function(config)
						mason_dap.default_setup(config)
					end,
					-- nvim-dap-python owns the Python adapter/configurations.
					python = function(_) end,
				},
			})

			local debugpy_python = vim.fs.joinpath(
				vim.fn.stdpath("data"),
				"mason",
				"packages",
				"debugpy",
				"venv",
				"bin",
				"python"
			)
			local dap_python = require("dap-python")
			dap_python.setup(debugpy_python)
			dap_python.test_runner = "pytest"
			dap_python.resolve_python = resolve_python

			-- Resolve the executable when a debug session starts. The previous
			-- `vim.fn.expand("%:r")` was evaluated while loading the config.
			dap.configurations.cpp = {
				{
					name = "C++: launch current target",
					type = "codelldb",
					request = "launch",
					program = function()
						local candidate = vim.fn.expand("%:r")
						if candidate ~= "" and vim.fn.executable(candidate) == 1 then
							return candidate
						end
						return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}
			dap.configurations.c = dap.configurations.cpp

			-- ML profile: step into Python dependencies and follow child Python
			-- processes. This does not debug CUDA kernels themselves.
			table.insert(dap.configurations.python, {
				name = "Python: current file (ML/dependencies)",
				type = "python",
				request = "launch",
				program = "${file}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				justMyCode = false,
				subProcess = true,
				pythonPath = resolve_python,
			})

			table.insert(dap.configurations.python, {
				name = "Python: attach localhost:5678",
				type = "python",
				request = "attach",
				connect = { host = "127.0.0.1", port = 5678 },
				justMyCode = false,
			})

			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.6 },
							{ id = "console", size = 0.4 },
						},
						position = "left",
						size = 40,
					},
				},
			})

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

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

			local wk = require("which-key")
			wk.add({
				{ "<leader>d", group = "Отладка" },
				{ "<leader>dt", dap.toggle_breakpoint, desc = "Точка останова" },
				{ "<leader>dc", dap.continue, desc = "Продолжить / запустить" },
				{ "<leader>di", dap.step_into, desc = "Шаг внутрь" },
				{ "<F4>", dap.step_over, desc = "Шаг через" },
				{ "<leader>du", dap.step_out, desc = "Шаг наружу" },
				{ "<leader>dp", dap.pause, desc = "Пауза" },
				{ "<leader>dr", function() dap.repl.open() end, desc = "REPL" },
				{ "<leader>dl", dap.run_last, desc = "Повторить запуск" },
				{
					"<leader>dh",
					function() require("dap.ui.widgets").hover() end,
					desc = "Значение под курсором",
				},
				{
					"<leader>dq",
					function()
						dap.terminate()
						dapui.close()
					end,
					desc = "Остановить отладку",
				},
				{ "<leader>db", dap.list_breakpoints, desc = "Точки останова" },
				{
					"<leader>de",
					function() dap.set_exception_breakpoints() end,
					desc = "Выбрать исключения для остановки",
				},
			})
		end,
	},
}
