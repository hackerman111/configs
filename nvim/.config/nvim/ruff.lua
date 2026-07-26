---@type vim.lsp.Config
return {
	init_options = {
		settings = {
			-- Доступно через code actions LSPsaga.
			fixAll = true,
			organizeImports = true,
		},
	},
}
