-- debug.lua: Улучшенная настройка nvim-dap для C++ и Rust с проверками

local dap = require("dap")
local dapui = require("dapui")

-- Setup DAP UI
dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "▴" },
	mappings = {
		open = "o",
		remove = "d",
		expand = { "<CR>", "<2-LeftMouse>" },
		open_cwd = ".",
		repl_toggle = "R",
	},
	expand_lines = vim.fn.has("nvim-0.7") == 1,
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			size = 40,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			size = 10,
			position = "bottom",
		},
	},
	floating = {
		max_height = nil,
		max_width = nil,
		border = "single",
		mappings = { close = { "q", "<Esc>" } },
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil,
		max_value_lines = 100,
	},
})

-- Автоматическое открытие/закрытие UI
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Безопасное получение пути к codelldb через Mason
local mason_registry = require("mason-registry")
local codelldb_path = nil
local codelldb_package = mason_registry.get_package("codelldb")

if codelldb_package then
	local extension_path = codelldb_package:get_install_path() .. "/extension"
	codelldb_path = extension_path .. "/adapter/codelldb"
	vim.notify("codelldb найден: " .. codelldb_path, vim.log.levels.INFO)
else
	-- Fallback: ручной путь (адаптируй под свою систему, если Mason не используется)
	-- Для Linux: ~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb
	-- Или скачай вручную с https://github.com/vadimcn/vscode-lldb/releases
	local fallback_path = vim.fn.expand("~/.local/share/nvim/mason/packages/codelldb/extension/adapter/codelldb")
	if vim.fn.filereadable(fallback_path) == 1 then
		codelldb_path = fallback_path
		vim.notify("codelldb fallback: " .. codelldb_path, vim.log.levels.WARN)
	else
		vim.notify("codelldb не установлен! Выполни :MasonInstall codelldb", vim.log.levels.ERROR)
		return -- Выходим, чтобы не крашить init.lua
	end
end

-- Адаптер для codelldb (общий для C++/Rust)
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = codelldb_path,
		args = { "--port", "${port}" },
	},
}

-- Конфигурация для C++
dap.configurations.cpp = {
	{
		name = "Launch C++ (codelldb)",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = function()
			local args = vim.fn.input("Arguments: ")
			return vim.split(args, " +")
		end,
		env = function()
			return vim.tbl_extend("keep", os.getenv(), { RUST_BACKTRACE = "1" })
		end,
	},
}

-- Конфигурация для Rust (с автоматической сборкой Cargo)
dap.configurations.rust = {
	{
		name = "Launch Rust (codelldb)",
		type = "codelldb",
		request = "launch",
		program = function()
			local bin_name = vim.fn.expand("%:t:r")
			local cargo_cmd = { "cargo", "build", "--bin", bin_name }
			local cargo_out = vim.fn.system(cargo_cmd)
			if vim.v.shell_error ~= 0 then
				vim.notify("Cargo build failed: " .. cargo_out, vim.log.levels.ERROR)
				return nil
			end
			return vim.fn.input(
				"Path to executable (default: target/debug/" .. bin_name .. "): ",
				vim.fn.getcwd() .. "/target/debug/" .. bin_name,
				"file"
			)
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = function()
			local args = vim.fn.input("Arguments: ")
			return vim.split(args, " +")
		end,
		sourceLanguages = { "rust" },
		initCommands = function()
			local rust_src = os.getenv("RUST_SRC_PATH")
			if not rust_src then
				vim.notify("Warning: RUST_SRC_PATH not set. Run 'rustup component add rust-src'", vim.log.levels.WARN)
				return {}
			end
			return {
				"command source-map enable",
				"settings set target.source-map /rustc/ " .. rust_src,
			}
		end,
	},
}

-- Базовые keymaps
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
map("n", "<F12>", dap.step_out, { desc = "DAP: Step Out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set Conditional Breakpoint" })
map("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
map("n", "<leader>dl", dap.run_last, { desc = "DAP: Run Last" })
map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })

-- Автокоманды для REPL
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dap-repl",
	callback = function()
		require("dap.repl").append_commands({
			{ "<Up>", "<C-p>" },
			{ "<Down>", "<C-n>" },
			{
				"<Tab>",
				function()
					require("dap.repl").close()
				end,
			},
		})
	end,
})

vim.notify("nvim-dap configured for C++ and Rust (with safety checks)!", vim.log.levels.INFO)
