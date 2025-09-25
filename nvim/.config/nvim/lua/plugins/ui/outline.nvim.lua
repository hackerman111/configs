return {
	-- Заменяем 'simrat39/symbols-outline.nvim' на 'hedyhli/outline.nvim'
	"hedyhli/outline.nvim",
	lazy = true,
	cmd = { "Outline", "OutlineOpen" },
	keys = {
		-- Горячая клавиша для открытия, полностью совместима с which-key
		{ "<Leader>o", "<cmd>Outline<CR>", desc = "Структура документа" },
	},
	opts = {
		-- В этом плагине все настройки находятся внутри таблицы 'opts'
		-- Это стандарт для современных плагинов и lazy.nvim

		-- Настройки окна
		width = 25,
		autofold_depth = 3,

		-- Секция для клавиш
		keymaps = {
			-- Просто нажмите '?' в окне Outline, чтобы увидеть это меню!
			close = { "<Esc>", "q" }, -- Закрыть окно
			goto_location = "<Cr>", -- Перейти к расположению символа
			focus_location = "o", -- Сфокусироваться на расположении
			hover_symbol = "<C-space>", -- Показать документацию (hover)
			toggle_preview = "K", -- Включить/выключить предпросмотр
			rename_symbol = "r", -- Переименовать символ
			code_actions = "a", -- Действия с кодом
			fold = "h", -- Свернуть узел
			unfold = "l", -- Развернуть узел
			fold_all = "W", -- Свернуть все узлы
			unfold_all = "E", -- Развернуть все узлы
			fold_reset = "R", -- Сбросить сворачивание
			show_help = "?", -- 💡 Показать это меню помощи
		},
	},
}
