local M = {}

local servers = {
	"lua_ls",
	"ty",
	"jedi_language_server",
	"ruff",
	"clangd",
	"rust_analyzer",
	"texlab",
	"marksman",
}

local function quickfix()
	vim.lsp.buf.code_action({
		apply = true,
		context = {
			only = { "quickfix" },
		},
	})
end

local function configure_lsp_capability()
	-- COQ v2 под Nvim 0.12 уже использует native capabilities.
	-- lsp_ensure_capabilities там оставлен только как compatibility no-op.
	if vim.fn.has("nvim-0.12") == 1 then
		return
	end

	-- COQ v1 / Nvim 0.11.
	local coq = require("coq")
	vim.lsp.config("*", coq.lsp_ensure_capabilities({}))
end

local function make_jedi_docs_only(client)
	local caps = client.server_capabilities

	-- Jedi здесь не должен конкурировать с ty/Ruff.
	caps.completionProvider = nil
	caps.definitionProvider = nil
	caps.declarationProvider = nil
	caps.typeDefinitionProvider = nil
	caps.implementationProvider = nil
	caps.referencesProvider = nil
	caps.renameProvider = nil
	caps.codeActionProvider = nil
	caps.documentSymbolProvider = nil
	caps.workspaceSymbolProvider = nil
	caps.documentHighlightProvider = nil
	caps.semanticTokensProvider = nil
	caps.inlayHintProvider = nil
	caps.documentFormattingProvider = nil
	caps.documentRangeFormattingProvider = nil
	caps.documentOnTypeFormattingProvider = nil
	caps.callHierarchyProvider = nil
	caps.typeHierarchyProvider = nil

	-- НЕ трогаем:
	--
	-- caps.hoverProvider
	-- caps.signatureHelpProvider
	--
	-- Это единственные интересующие нас функции Jedi.
end

local function configure_lsp_attaches()
	local group = vim.api.nvim_create_augroup("user-lsp-attaches", { clear = true })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,

		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)

			vim.keymap.set("n", "<leader>cf", quickfix, {
				buffer = event.buf,
				desc = "Apply quick fix",
			})

			if not client then
				return
			end

			if client.name == "ty" then
				-- Completion/diagnostics/navigation остаются у ty.
				--
				-- Но K/Lspsaga hover и lsp_signature для Python
				-- теперь получают данные от Jedi.
				client.server_capabilities.hoverProvider = nil
				client.server_capabilities.signatureHelpProvider = nil
			end

			if client.name == "jedi_language_server" then
				make_jedi_docs_only(client)
			end

			if client.name == "ruff" then
				client.server_capabilities.hoverProvider = false

				-- Форматирование централизовано через Conform.
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end

			if client.name == "texlab" then
				-- В твоём blink.lua completion полностью
				-- выключен для tex.
				client.server_capabilities.completionProvider = nil
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
