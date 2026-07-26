---@type vim.lsp.Config
return {
	settings = {
		texlab = {
			-- Сборкой управляет VimTeX.
			build = {
				onSave = false,
				forwardSearchAfter = false,
			},

			-- Проверка LaTeX через ChkTeX.
			chktex = {
				onOpenAndSave = true,
				onEdit = false,
			},

			diagnosticsDelay = 300,

			-- Texlab продолжает поддерживать ручное форматирование.
			latexFormatter = "latexindent",

			latexindent = {
				modifyLineBreaks = false,
			},

			bibtexFormatter = "texlab",
			formatterLineLength = 100,
		},
	},
}
