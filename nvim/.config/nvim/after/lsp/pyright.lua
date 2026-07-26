---@type vim.lsp.Config
return {
	settings = {
		pyright = {
			-- Сортировкой и удалением импортов занимается Ruff.
			disableOrganizeImports = true,
		},

		python = {
			analysis = {
				-- Поведение прошлого коммита: не индексировать закрытые файлы
				-- всего workspace перед ответом на hover/completion.
				diagnosticMode = "openFilesOnly",
				typeCheckingMode = "standard",
				autoSearchPaths = true,
				autoImportCompletions = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}
