-- Нужно:
-- автодополнение через blink
-- Документация через LSP saga
-- Подсветка ошибок

local M = {}
local servers = {
	"lua_ls",
	"ty",
	"pyrefly",
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
			if client.name == "pyrefly" then
				-- Completion предоставляет ty, чтобы blink не показывал дубликаты.
				client.server_capabilities.completionProvider = nil
			end
			if client.name == "ruff" then
				client.server_capabilities.hoverProvider = false

				-- Форматирование запускается централизованно через Conform.
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end
		end,
	})
end

function M.setup()
	configure_lsp_capability()
	configure_lsp_attaches()
	vim.lsp.enable(servers)
end

return M
