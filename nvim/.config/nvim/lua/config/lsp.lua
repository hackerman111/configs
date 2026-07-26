-- Нужно:
-- автодополнение через blink
-- Документация через LSP saga
-- Подсветка ошибок

local M = {}

local servers = {
	"lua_ls",
	"pyright",
	"ruff",
	"clangd",
	"rust_analyzer",
	"texlab",
	"marksman",
}

local function configure_lsp_capability()
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	vim.lsp.config("*", {
		capabilities = capabilities,
	})
end

local function configure_diagnostics()
	vim.diagnostic.config({
		virtual_text = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			source = true,
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚 ",
				[vim.diagnostic.severity.WARN] = "󰀪 ",
				[vim.diagnostic.severity.INFO] = "󰋽 ",
				[vim.diagnostic.severity.HINT] = "󰌶 ",
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "ErrorMsg",
				[vim.diagnostic.severity.WARN] = "WarningMsg",
			},
		},
	})
end

local function configure_lsp_attaches()
	local group = vim.api.nvim_create_augroup("user-lsp-attaches", {
		clear = true,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)

			if not client then
				return
			end

			-- Ruff отвечает за lint и code actions.
			-- Hover и типы предоставляет Pyright.
			if client.name == "ruff" then
				client.server_capabilities.hoverProvider = false
				-- Python форматируют Black и isort через Conform.
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end
		end,
	})
end

local function create_lsp_commands()
	vim.api.nvim_create_user_command("LspRestart", function()
		local bufnr = vim.api.nvim_get_current_buf()
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			client:stop()
		end

		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd.edit()
				end)
			end
		end, 100)
	end, { desc = "Перезапустить LSP текущего буфера" })

	vim.api.nvim_create_user_command("LspStatus", function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			print("󰅚 No LSP clients attached")
			return
		end

		for _, client in ipairs(clients) do
			print(string.format("󰌘 %s (id=%d, root=%s)", client.name, client.id, client.root_dir or "N/A"))
		end
	end, { desc = "Показать LSP-клиенты текущего буфера" })

	vim.api.nvim_create_user_command("LspCapabilities", function()
		local capability_names = {
			{ "completion", "completionProvider" },
			{ "hover", "hoverProvider" },
			{ "definition", "definitionProvider" },
			{ "references", "referencesProvider" },
			{ "document symbols", "documentSymbolProvider" },
			{ "code actions", "codeActionProvider" },
			{ "formatting", "documentFormattingProvider" },
			{ "rename", "renameProvider" },
		}

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
			local enabled = {}
			for _, capability in ipairs(capability_names) do
				if client.server_capabilities[capability[2]] then
					enabled[#enabled + 1] = capability[1]
				end
			end
			print(string.format("%s: %s", client.name, table.concat(enabled, ", ")))
		end
	end, { desc = "Показать возможности LSP-клиентов" })

	vim.api.nvim_create_user_command("LspDiagnostics", function()
		local counts = { 0, 0, 0, 0 }
		for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
			counts[diagnostic.severity] = counts[diagnostic.severity] + 1
		end

		print(
			string.format(
				"Errors: %d, Warnings: %d, Info: %d, Hints: %d",
				counts[vim.diagnostic.severity.ERROR],
				counts[vim.diagnostic.severity.WARN],
				counts[vim.diagnostic.severity.INFO],
				counts[vim.diagnostic.severity.HINT]
			)
		)
	end, { desc = "Показать число диагностик текущего буфера" })

	vim.api.nvim_create_user_command("LspInfo", function()
		print("LSP log: " .. vim.lsp.get_log_path())
		print("Filetype: " .. vim.bo.filetype)
		print("Buffer: " .. vim.api.nvim_get_current_buf())
		vim.cmd.LspStatus()
	end, { desc = "Показать сводную информацию LSP" })
end

function M.setup()
	configure_lsp_capability()
	configure_diagnostics()
	configure_lsp_attaches()
	create_lsp_commands()
	vim.lsp.enable(servers)
end

return M
