-- ~/.config/nvim/lua/plugins/text-case_nvim.lua

return {
	"johmsalas/text-case.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("textcase").setup({
			-- ИСПРАВЛЕНИЕ: Заменяем кириллическое имя на латинское
			substitude_command_name = "Substitute",

			-- Переопределяем названия (labels) для всех стилей
			cases = {
				camel = {
					label = "Верблюжий Регистр (camelCase)",
				},
				pascal = {
					label = "Стиль Pascal (PascalCase)",
				},
				snake = {
					label = "Змеиный_Регистр (snake_case)",
				},
				kebab = {
					label = "Шашлычный-Регистр (kebab-case)",
				},
				const = {
					label = "РЕГИСТР_КОНСТАНТ (SCREAMING_SNAKE_CASE)",
				},
				dot = {
					label = "Точечный.Регистр (dot.case)",
				},
				path = {
					label = "Стиль/Пути (path/case)",
				},
				title = {
					label = "Заголовочный Стиль (Title Case)",
				},
				sentence = {
					label = "Стиль Предложений (Sentence case)",
				},
				upper = {
					label = "ВСЕ ЗАГЛАВНЫЕ (UPPER CASE)",
				},
				lower = {
					label = "все строчные (lower case)",
				},
				toggle = {
					label = "Инвертировать РЕгиСТР (Toggle Case)",
				},
			},
		})
		require("move_and_navigation.telescope").load_extension("textcase")
	end,
	keys = {
		"ga", -- Default invocation prefix
		{ "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "x" }, desc = "Telescope" },
	},
}
