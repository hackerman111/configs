return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-python",
		},
		keys = {
			{ "<leader>Tr", function() require("neotest").run.run() end, desc = "Тест: ближайший" },
			{ "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Тест: файл" },
			{
				"<leader>Ta",
				function()
					local root = vim.fs.root(0, { "pyproject.toml", "Cargo.toml", "CMakeLists.txt", "package.json", ".git" })
					require("neotest").run.run(root or vim.fn.getcwd())
				end,
				desc = "Тест: проект",
			},
			{ "<leader>Tl", function() require("neotest").run.run_last() end, desc = "Тест: повторить" },
			{ "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Тест: debug" },
			{ "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Тесты: дерево" },
			{ "<leader>To", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Тест: вывод" },
			{ "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Тесты: панель вывода" },
			{ "<leader>Tx", function() require("neotest").run.stop() end, desc = "Тест: остановить" },
			{ "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Тест: watch файла" },
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-python")({
						runner = "pytest",
						python = require("config.python").resolve_python,
						dap = { justMyCode = false },
					}),
				},
				output = { open_on_run = false },
				quickfix = { open = false },
			})

			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.add({ { "<leader>T", group = "Тесты" } })
			end
		end,
	},
}
