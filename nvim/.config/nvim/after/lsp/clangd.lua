---@type vim.lsp.Config
return {
	cmd = {
		"clangd",

		-- Индекс проекта хранится между запусками.
		"--background-index",

		-- Диагностика clang-tidy через clangd.
		"--clang-tidy",

		-- Более подробные элементы автодополнения для Blink.
		"--completion-style=detailed",

		-- Предлагать и автоматически добавлять заголовочные файлы.
		"--header-insertion=iwyu",
	},
}
