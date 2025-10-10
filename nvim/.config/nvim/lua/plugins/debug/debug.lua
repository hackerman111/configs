-- Assuming you use lazy.nvim for plugin management
-- Place this in your plugins file or init.lua

return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
		},

		config = function()
			local mason_dap = require("mason-nvim-dap")
			local dap = require("dap")
			local ui = require("dapui")
			local dap_virtual_text = require("nvim-dap-virtual-text")

			-- Dap Virtual Text
			dap_virtual_text.setup()

			mason_dap.setup({
				ensure_installed = { "codelldb" },
				automatic_installation = true,
				handlers = {
					function(config)
						require("mason-nvim-dap").default_setup(config)
					end,
				},
			})

			-- Configurations
			dap.configurations.cpp = {
				{
					name = "runit",
					type = "codelldb",
					request = "launch",

					program = vim.fn.expand("%:r"),

					args = { "--log_level=all" },
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					terminal = "integrated",
				},
			}

			-- Dap UI

			ui.setup({
				-- Переопределяем стандартные макеты на свой собственный
				layouts = {
					{
						-- Список элементов, которые будут отображаться в этой панели
						elements = {
							-- id элемента, 'size' отвечает за долю занимаемого места по вертикали
							{ id = "scopes", size = 0.6 }, -- 40% высоты панели
							{ id = "console", size = 0.2 }, -- 60% высоты панели
						},
						-- Расположение панели (может быть 'left', 'right', 'bottom')
						position = "left",
						-- Ширина панели в символах
						size = 40,
					},
				},
				-- Можно также настроить другие опции, если нужно
				-- controls = { enabled = true },
				-- floating = { max_height = nil, max_width = nil },
			})

			vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
			local wk = require("which-key")
			wk.add({
				-- Debugger
				{
					"<leader>d",
					group = "Debugger",
					nowait = true,
					remap = false,
				},
				{
					"<leader>dt",
					function()
						require("dap").toggle_breakpoint()
					end,
					desc = "Toggle Breakpoint",
					nowait = true,
					remap = false,
				},
				{
					"<leader>dc",
					function()
						require("dap").continue()
					end,
					desc = "Continue",
					nowait = true,
					remap = false,
				},
				{
					"<leader>di",
					function()
						require("dap").step_into()
					end,
					desc = "Step Into",
					nowait = true,
					remap = true,
				},
				{
					"<F4>",
					function()
						require("dap").step_over()
					end,
					desc = "Step Over",
					nowait = true,
					remap = false,
				},
				{
					"<leader>du",
					function()
						require("dap").step_out()
					end,
					desc = "Step Out",
					nowait = true,
					remap = false,
				},
				{
					"<leader>dr",
					function()
						require("dap").repl.open()
					end,
					desc = "Open REPL",
					nowait = true,
					remap = false,
				},
				{
					"<leader>dl",
					function()
						require("dap").run_last()
					end,
					desc = "Run Last",
					nowait = true,
					remap = false,
				},
				{
					"<leader>dq",
					function()
						require("dap").terminate()
						require("dapui").close()
						require("nvim-dap-virtual-text").toggle()
					end,
					desc = "Terminate",
					nowait = true,
					remap = false,
				},
				{
					"<leader>db",
					function()
						require("dap").list_breakpoints()
					end,
					desc = "List Breakpoints",
					nowait = true,
					remap = false,
				},
				{
					"<leader>de",
					function()
						require("dap").set_exception_breakpoints({ "all" })
					end,
					desc = "Set Exception Breakpoints",
					nowait = true,
					remap = false,
				},
			})
		end,
	},
}
