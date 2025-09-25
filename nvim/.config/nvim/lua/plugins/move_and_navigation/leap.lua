-- ~/.config/nvim/lua/plugins/navigation.lua

return {
	-- ОСНОВНОЙ ПЛАГИН: Flash для большинства перемещений
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type flash.Config
		opts = {
			-- Режимы для поиска и перемещения
			modes = {
				-- Отключаем стандартный поиск по 's', так как будем использовать leap/flit
				char = {
					enabled = false,
				},
				search = {
					enabled = true,
					-- Используем 's' для активации поиска flash
					trigger = "s",
					-- При наборе одного символа, flash будет вести себя как команда f
					multi_window = true,
				},
				-- Интеграция с Treesitter для прыжков по узлам синтаксического дерева
				treesitter = {
					enabled = true,
					-- Можно задать горячую клавишу для прыжка к определенному узлу
					-- keymaps = {
					--   ["<leader>fj"] = "function_definition",
					-- },
				},
			},
		},
		-- Переопределяем стандартные клавиши для интеграции с flash
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					-- 's' запускает flash
					require("flash").jump()
				end,
				desc = "Flash Jump",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					-- 'S' запускает flash во всех окнах
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Flash Remote",
			},
			{
				"<leader>l", -- Клавиша для вызова прыжка
				mode = { "n", "x", "o" },
				function()
					-- ⚙️ Здесь мы используем вашу адаптированную функцию
					require("flash").jump({
						pattern = "^",
						label = { after = { 0, 0 } },
						search = { mode = "search" }, -- max_length можно убрать для ясности
					})
				end,
				desc = "Flash: прыжок в начало строки",
			},
		},
	},

	-- УЛУЧШЕННЫЕ f/t: Flit для точной навигации по строке
	{
		"ggandor/flit.nvim",
		event = "VeryLazy",
		dependencies = { "ggandor/leap.nvim" },
		config = function()
			require("flit").setup({
				-- Используем стандартные клавиши f, F, t, T
				keys = { f = "f", F = "F", t = "t", T = "T" },
				-- Включаем метки во всех режимах для наглядности
				labeled_modes = "nox",
				-- Повторение команды по той же клавише (например, f -> ;)
				clever_repeat = true,
			})
		end,
	},
}
