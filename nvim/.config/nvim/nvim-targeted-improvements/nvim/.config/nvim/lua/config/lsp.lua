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
	vim.lsp.config("*", {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
	})
end

local function code_action(kind)
	vim.lsp.buf.code_action({
		apply = true,
		context = { only = { kind } },
	})
end

local function configure_lsp_attaches()
	local group = vim.api.nvim_create_augroup("user-lsp-attaches", { clear = true })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client then
				return
			end

			-- Completion is currently owned by ty. Pyrefly still produces its
			-- diagnostics/navigation unless you remove it from `servers`.
			if client.name == "pyrefly" then
				client.server_capabilities.completionProvider = nil
			end

			-- Ruff provides diagnostics and code actions; Conform owns formatting.
			if client.name == "ruff" then
				client.server_capabilities.hoverProvider = false
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end

			if client:supports_method("textDocument/codeAction", event.buf) then
				local opts = { buffer = event.buf, silent = true }
				vim.keymap.set({ "n", "v" }, "<leader>cf", function()
					code_action("quickfix")
				end, vim.tbl_extend("force", opts, { desc = "Быстрый code action" }))
				vim.keymap.set("n", "<leader>cF", function()
					code_action("source.fixAll.ruff")
				end, vim.tbl_extend("force", opts, { desc = "Ruff: безопасный fix all" }))
				vim.keymap.set("n", "<leader>ci", function()
					code_action("source.organizeImports.ruff")
				end, vim.tbl_extend("force", opts, { desc = "Ruff: организовать импорты" }))
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
