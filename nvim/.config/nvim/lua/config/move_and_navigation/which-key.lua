local M = {}

local function icon(glyph, color)
	return { icon = glyph, color = color }
end

M.opts = {
	preset = "modern",
	delay = function(ctx)
		return ctx.plugin and 0 or 160
	end,
	filter = function()
		return true
	end,
	spec = {},
	notify = true,
	triggers = {
		{ "<auto>", mode = "nixsotc" },
		-- Встроенные одноклавишные префиксы Vim не получают автоматический триггер.
		{ "g", mode = { "n", "x", "o" } },
		{ "z", mode = { "n", "x", "o" } },
		{ "[", mode = { "n", "x", "o" } },
		{ "]", mode = { "n", "x", "o" } },
		{ "<C-w>", mode = "n" },
		{ "<C-x>", mode = "i" },
	},
	defer = function(ctx)
		if vim.list_contains({ "d", "y", "c", "=", ">", "<", "g~", "gu", "gU", "gq", "zf" }, ctx.operator) then
			return true
		end
		return ctx.mode == "V" or ctx.mode == "<C-V>"
	end,
	plugins = {
		marks = true,
		registers = true,
		spelling = {
			enabled = true,
			suggestions = 20,
		},
		presets = {
			operators = true,
			motions = true,
			text_objects = true,
			windows = true,
			nav = true,
			z = true,
			g = true,
		},
	},
	win = {
		no_overlap = true,
		border = "rounded",
		padding = { 1, 2 },
		title = " Клавиши ",
		title_pos = "center",
		zindex = 1000,
		bo = {},
		wo = {
			winblend = 0,
		},
	},
	layout = {
		width = { min = 24, max = 46 },
		spacing = 4,
	},
	keys = {
		scroll_down = "<C-d>",
		scroll_up = "<C-u>",
	},
	sort = { "local", "order", "group", "alphanum", "mod" },
	expand = 1,
	replace = {
		key = {
			function(key)
				return require("which-key.view").format(key)
			end,
		},
		desc = {
			{ "<Plug>%(?(.*)%)?", "%1" },
			{ "^%+", "" },
			{ "<[cC]md>", "" },
			{ "<[cC][rR]>", "" },
			{ "<[sS]ilent>", "" },
			{ "^lua%s+", "" },
			{ "^call%s+", "" },
			{ "^:%s*", "" },
		},
	},
	icons = {
		breadcrumb = "›",
		separator = "→",
		group = "󰐕 ",
		ellipsis = "…",
		mappings = true,
		rules = {},
		colors = true,
		keys = {
			Up = " ",
			Down = " ",
			Left = " ",
			Right = " ",
			C = "󰘴 ",
			M = "󰘵 ",
			D = "󰘳 ",
			S = "󰘶 ",
			CR = "󰌑 ",
			Esc = "󱊷 ",
			ScrollWheelDown = "󱕐 ",
			ScrollWheelUp = "󱕑 ",
			NL = "󰌑 ",
			BS = "󰁮 ",
			Space = "󱁐 ",
			Tab = "󰌒 ",
			F1 = "󱊫 ",
			F2 = "󱊬 ",
			F3 = "󱊭 ",
			F4 = "󱊮 ",
			F5 = "󱊯 ",
			F6 = "󱊰 ",
			F7 = "󱊱 ",
			F8 = "󱊲 ",
			F9 = "󱊳 ",
			F10 = "󱊴 ",
			F11 = "󱊵 ",
			F12 = "󱊶 ",
		},
	},
	show_help = true,
	show_keys = true,
	disable = {
		ft = { "alpha", "dashboard" },
		bt = { "prompt" },
	},
	debug = false,
}

local function register_main_groups(wk)
	wk.add({
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Сочетания текущего буфера",
			icon = icon("󰌌 ", "cyan"),
		},

		{ "<leader>a", group = "Агенты и терминал", icon = icon(" ", "green") },
		{ "<leader>c", group = "Действия с кодом", icon = icon("󰅩 ", "yellow") },
		{ "<leader>d", group = "Отладка", icon = icon(" ", "red") },
		{ "<leader>f", group = "Файлы и поиск", icon = icon("󰱼 ", "azure") },
		{
			"<leader>g",
			group = "Форматирование и диагностика",
			icon = icon("󰁨 ", "orange"),
		},
		{ "<leader>h", group = "Harpoon", icon = icon("󰛢 ", "purple") },
		{ "<leader>l", group = "LSP и структура", icon = icon("󰒋 ", "cyan") },
		{ "<leader>L", group = "LaTeX", icon = icon("󰙩 ", "green") },
		{ "<leader>r", group = "Переименование", icon = icon("󰑕 ", "yellow") },
		{ "<leader>s", group = "Поиск и замена", icon = icon("󰛔 ", "orange") },
		{ "<leader>t", group = "Диагностика и символы", icon = icon("󱖫 ", "red") },
		{ "<leader>w", group = "Окна", icon = icon("󰖲 ", "blue") },

		{ "<leader>at", desc = "Открыть плавающий терминал", icon = icon(" ", "green") },
		{ "<leader>ca", desc = "Действия LSP с кодом" },

		{ "<leader>dt", desc = "Переключить точку останова" },
		{ "<leader>dc", desc = "Продолжить выполнение" },
		{ "<leader>di", desc = "Шаг внутрь" },
		{ "<leader>du", desc = "Шаг наружу" },
		{ "<leader>dr", desc = "Открыть REPL" },
		{ "<leader>dl", desc = "Повторить последний запуск" },
		{ "<leader>dq", desc = "Остановить отладку" },
		{ "<leader>db", desc = "Показать точки останова" },
		{ "<leader>de", desc = "Останавливать на исключениях" },

		{ "<leader>fd", desc = "Открыть файловый браузер" },
		{ "<leader>ff", desc = "Найти файл" },
		{ "<leader>fp", desc = "Найти часто используемый файл" },
		{ "<leader>fc", desc = "Найти файл в домашнем каталоге" },
		{ "<leader>fg", desc = "Найти по содержимому" },
		{ "<leader>fb", desc = "Найти открытый буфер" },
		{ "<leader>fo", desc = "Найти недавний файл" },
		{ "<leader>fe", desc = "Найти диагностику текущего файла" },
		{ "<leader>fz", desc = "Перейти в каталог через Zoxide" },
		{ "<leader>fr", desc = "Найти проект" },
		{ "<leader>fh", desc = "Открыть список Harpoon через Telescope" },

		{ "<leader>gf", desc = "Форматировать код" },
		{ "<leader>gl", desc = "Запустить проверку линтером" },
		{ "<leader>gD", desc = "Показать диагностику строки" },

		{ "<leader>ha", desc = "Добавить файл в Harpoon" },
		{ "<leader>hn", desc = "Следующий файл Harpoon" },
		{ "<leader>hp", desc = "Предыдущий файл Harpoon" },
		{ "<leader>hr", desc = "Удалить файл из Harpoon" },
		{ "<leader>hc", desc = "Очистить список Harpoon" },

		{ "<leader>lo", desc = "Открыть структуру файла Lspsaga" },
		{ "<leader>LL", desc = "Собрать LaTeX-документ" },
		{ "<leader>rn", desc = "Переименовать символ под курсором" },

		{ "<leader>S", desc = "Открыть Spectre" },
		{ "<leader>sw", desc = "Найти текущее слово", mode = { "n", "x" } },
		{ "<leader>sp", desc = "Искать в текущем файле" },
		{ "<leader>sr", desc = "Структурная замена", mode = { "n", "x" } },

		{ "<leader>tt", desc = "Диагностика текущего файла" },
		{ "<leader>tT", desc = "Диагностика проекта" },
		{ "<leader>ts", desc = "Символы текущего файла" },

		{ "<leader>wh", desc = "Перейти в окно слева" },
		{ "<leader>wj", desc = "Перейти в окно снизу" },
		{ "<leader>wk", desc = "Перейти в окно сверху" },
		{ "<leader>wl", desc = "Перейти в окно справа" },
		{ "<leader>ww", desc = "Перейти в следующее окно" },
		{ "<leader>wp", desc = "Вернуться в предыдущее окно" },
		{ "<leader>wv", desc = "Разделить окно вертикально" },
		{ "<leader>ws", desc = "Разделить окно горизонтально" },
		{ "<leader>wc", desc = "Закрыть текущее окно" },
		{ "<leader>wo", desc = "Оставить только текущее окно" },
		{ "<leader>w=", desc = "Выровнять размеры окон" },

		{ "<leader>m", desc = "Запустить множественные курсоры", mode = { "n", "x" } },
		{ "<leader>o", desc = "Открыть структуру документа" },
		{ "<leader>p", desc = "Открыть историю копирования", mode = { "n", "x" } },
	})
end

local function register_custom_mappings(wk)
	wk.add({
		{ "<Esc>", desc = "Сбросить подсветку поиска", mode = "n" },
		{ "<Left>", desc = "Используйте h для движения влево", mode = "n" },
		{ "<Down>", desc = "Используйте j для движения вниз", mode = "n" },
		{ "<Up>", desc = "Используйте k для движения вверх", mode = "n" },
		{ "<Right>", desc = "Используйте l для движения вправо", mode = "n" },
		{ "yy", desc = "Скопировать строку в системный буфер", mode = "n" },
		{ "y", desc = "Скопировать текст", mode = { "n", "x" } },
		{ "p", desc = "Вставить после курсора", mode = { "n", "x" } },
		{ "P", desc = "Вставить перед курсором", mode = { "n", "x" } },
		{ "gp", desc = "Вставить после выделения", mode = { "n", "x" } },
		{ "gP", desc = "Вставить перед выделением", mode = { "n", "x" } },
		{ ">p", desc = "Вставить и сместить вправо", mode = "n" },
		{ "<p", desc = "Вставить и сместить влево", mode = "n" },
		{ ">P", desc = "Вставить перед курсором и сместить вправо", mode = "n" },
		{ "<P", desc = "Вставить перед курсором и сместить влево", mode = "n" },
		{ "=p", desc = "Вставить после форматирования", mode = "n" },
		{
			"=P",
			desc = "Вставить перед курсором после форматирования",
			mode = "n",
		},
		{ "-", desc = "Открыть родительский каталог", mode = "n" },
		{ "<Tab>", desc = "Следующая вкладка", mode = "n" },
		{ "<S-Tab>", desc = "Предыдущая вкладка", mode = "n" },
		{ "<Tab>", desc = "LuaSnip: следующий узел", mode = { "i", "s" } },
		{ "<S-Tab>", desc = "LuaSnip: предыдущий узел", mode = { "i", "s" } },
		{ "<Tab>", desc = "LuaSnip: сохранить выделение", mode = "x" },
		{
			"<C-Space>",
			desc = "Расширить синтаксическое выделение",
			mode = { "n", "x" },
		},
		{ "<BS>", desc = "Сузить синтаксическое выделение", mode = "x" },

		{ "<C-h>", desc = "Перейти в окно слева", mode = "n" },
		{ "<C-j>", desc = "Перейти в окно снизу", mode = "n" },
		{ "<C-k>", desc = "Перейти в окно сверху", mode = "n" },
		{ "<C-l>", desc = "Перейти в окно справа", mode = "n" },
		{ "<C-\\>", desc = "Вернуться в предыдущее окно", mode = "n" },
		{ "<C-e>", desc = "Открыть быстрое меню Harpoon", mode = "n" },
		{ "<C-p>", desc = "Предыдущая запись истории вставки", mode = "n" },
		{ "<C-n>", desc = "Следующая запись истории вставки", mode = "n" },

		{ "<C-f>", desc = "Открыть фигуры Inkscape", mode = "n" },
		{ "<C-f>", desc = "Создать фигуру через Inkscape", mode = "i" },
		{ "<Esc>", desc = "Перейти в обычный режим", mode = "t" },
		{ "<C-h>", desc = "Из терминала в окно слева", mode = "t" },
		{ "<C-j>", desc = "Из терминала в окно снизу", mode = "t" },
		{ "<C-k>", desc = "Из терминала в окно сверху", mode = "t" },
		{ "<C-l>", desc = "Из терминала в окно справа", mode = "t" },
		{ "<F4>", desc = "Отладка: шаг через", mode = "n" },
		{ "<F5>", desc = "Не используется", hidden = true, mode = { "n", "i", "t" } },
		{ "<F12>", desc = "Открыть или закрыть терминал", mode = { "n", "i", "t" } },

		{ "K", desc = "Показать документацию LSP", mode = "n" },
		{ "gd", desc = "Перейти к определению", mode = "n" },
		{ "gD", desc = "Перейти к определению типа", mode = "n" },
		{ "ga", group = "Регистр текста", icon = icon("󰬴 ", "yellow"), mode = { "n", "x" } },
		{ "ga.", desc = "Выбрать стиль регистра через Telescope", mode = { "n", "x" } },

		{ "s", desc = "Flash: быстрый переход", mode = { "n", "x", "o" } },
		{ "gw", desc = "Flash: перейти к началу слова", mode = { "n", "x", "o" } },
		{ "ge", desc = "Flash: перейти к концу слова", mode = { "n", "x", "o" } },
		{ "gm", desc = "Flash: перейти к введённому тексту", mode = { "n", "x", "o" } },
		{ "S", desc = "Flash: выбрать синтаксический узел", mode = { "n", "o" } },
		{ "R", desc = "Flash: найти синтаксический узел", mode = { "x", "o" } },
		{ "r", desc = "Flash: удалённый переход оператора", mode = "o" },
		{ "<C-s>", desc = "Flash: переключить метки поиска", mode = "c" },
		{ "zs", desc = "Leap: перейти в текущем окне", mode = { "n", "x", "o" } },
		{ "zS", desc = "Leap: перейти в любом окне", mode = { "n", "x", "o" } },
		{ "f", desc = "Leap: найти символ вперёд", mode = { "n", "x", "o" } },
		{ "F", desc = "Leap: найти символ назад", mode = { "n", "x", "o" } },
		{ "t", desc = "Leap: перейти перед символом вперёд", mode = { "n", "x", "o" } },
		{ "T", desc = "Leap: перейти после символа назад", mode = { "n", "x", "o" } },

		{ "dsm", desc = "Vimtex: удалить математическое окружение", mode = "n" },
		{ "tsf", desc = "Vimtex: переключить математическое окружение", mode = "n" },
		{ "%", desc = "Vimtex: перейти к парной конструкции", mode = { "n", "x", "o" } },
		{ "ai", desc = "Vimtex: математическое окружение целиком", mode = { "x", "o" } },
		{
			"ii",
			desc = "Vimtex: содержимое математического окружения",
			mode = { "x", "o" },
		},
		{ "am", desc = "Vimtex: встроенная формула целиком", mode = { "x", "o" } },
		{ "im", desc = "Vimtex: содержимое встроенной формулы", mode = { "x", "o" } },

		{ "ys", group = "Добавить окружение", mode = "n" },
		{ "yss", desc = "Окружить текущую строку", mode = "n" },
		{ "yS", group = "Добавить окружение построчно", mode = "n" },
		{ "ySS", desc = "Окружить строку построчно", mode = "n" },
		{ "ds", group = "Удалить окружение", mode = "n" },
		{ "cs", group = "Изменить окружение", mode = "n" },
		{ "gS", desc = "Окружить выделение построчно", mode = "x" },
		{ "<C-g>s", desc = "Вставить окружение", mode = "i" },
		{ "<C-g>S", desc = "Вставить построчное окружение", mode = "i" },

		{ "gc", group = "Построчный комментарий", mode = { "n", "o" } },
		{ "gb", group = "Блочный комментарий", mode = { "n", "o" } },
		{ "gcc", desc = "Переключить комментарий строки", mode = "n" },
		{ "gbc", desc = "Переключить блочный комментарий", mode = "n" },
		{ "gco", desc = "Добавить комментарий ниже", mode = "n" },
		{ "gcO", desc = "Добавить комментарий выше", mode = "n" },
		{ "gcA", desc = "Добавить комментарий в конец строки", mode = "n" },
		{ "gc", desc = "Переключить комментарий выделения", mode = "x" },
		{ "gb", desc = "Переключить блочный комментарий выделения", mode = "x" },
		{ "*", desc = "Искать выделенный текст вперёд", mode = "x" },
		{ "#", desc = "Искать выделенный текст назад", mode = "x" },
		{ "@", desc = "Выполнить макрос для строк выделения", mode = "x" },
		{
			"Q",
			desc = "Повторить последний макрос для строк выделения",
			mode = "x",
		},
		{ "[%", desc = "К предыдущей непарной конструкции", mode = "x" },
		{ "]%", desc = "К следующей непарной конструкции", mode = "x" },
		{ "a%", desc = "Выделить парную конструкцию", mode = "x" },
		{ "g%", desc = "К предыдущей парной конструкции", mode = "x" },
		{ "<C-e>", desc = "Прокрутить окно вниз", mode = "x" },
		{ "<C-y>", desc = "Прокрутить окно вверх", mode = "x" },
		{ "<C-f>", desc = "Прокрутить на страницу вниз", mode = "x" },
		{ "<C-b>", desc = "Прокрутить на страницу вверх", mode = "x" },
		{ "<C-d>", desc = "Прокрутить на полстраницы вниз", mode = "x" },
		{ "<C-u>", desc = "Прокрутить на полстраницы вверх", mode = "x" },
	})
end

local function register_native_prefixes(wk)
	wk.add({
		{
			"g",
			group = "Переходы и дополнительные команды",
			icon = icon("󰆓 ", "azure"),
			mode = { "n", "x", "o" },
		},
		{
			"z",
			group = "Вид, сворачивание и орфография",
			icon = icon("󰘖 ", "purple"),
			mode = { "n", "x", "o" },
		},
		{ "[", group = "Предыдущий объект", icon = icon("󰒮 ", "cyan"), mode = { "n", "x", "o" } },
		{ "]", group = "Следующий объект", icon = icon("󰒭 ", "cyan"), mode = { "n", "x", "o" } },
		{ "<C-w>", group = "Окна Vim", icon = icon("󰖲 ", "blue"), mode = "n" },
		{ '"', group = "Регистры", icon = icon("󰅍 ", "yellow"), mode = { "n", "x" } },
		{ "'", group = "Метки по строке", icon = icon("󰃀 ", "orange"), mode = { "n", "x", "o" } },
		{ "`", group = "Метки по позиции", icon = icon("󰃀 ", "orange"), mode = { "n", "x", "o" } },

		-- Наиболее употребимые встроенные команды с префиксом g.
		{ "gg", desc = "Перейти к первой строке", mode = { "n", "x", "o" } },
		{ "g0", desc = "К началу экранной строки", mode = { "n", "x", "o" } },
		{
			"g^",
			desc = "К первому непробельному символу экранной строки",
			mode = { "n", "x", "o" },
		},
		{ "g$", desc = "К концу экранной строки", mode = { "n", "x", "o" } },
		{
			"g_",
			desc = "К последнему непробельному символу строки",
			mode = { "n", "x", "o" },
		},
		{ "gj", desc = "На экранную строку вниз", mode = { "n", "x", "o" } },
		{ "gk", desc = "На экранную строку вверх", mode = { "n", "x", "o" } },
		{ "g;", desc = "К предыдущему изменению", mode = "n" },
		{ "g,", desc = "К следующему изменению", mode = "n" },
		{ "gi", desc = "К месту последней вставки", mode = "n" },
		{ "gv", desc = "Повторно выделить последнюю область", mode = "n" },
		{ "gf", desc = "Открыть файл под курсором", mode = "n" },
		{
			"gF",
			desc = "Открыть файл под курсором на указанной строке",
			mode = "n",
		},
		{
			"gx",
			desc = "Открыть ссылку или файл внешней программой",
			mode = { "n", "x" },
		},
		{ "gt", desc = "Следующая вкладка Vim", mode = "n" },
		{ "gT", desc = "Предыдущая вкладка Vim", mode = "n" },
		{ "g*", desc = "Искать слово под курсором вперёд", mode = "n" },
		{ "g#", desc = "Искать слово под курсором назад", mode = "n" },
		{ "g~", group = "Изменить регистр", mode = { "n", "x", "o" } },
		{ "gu", group = "Преобразовать в строчные", mode = { "n", "x", "o" } },
		{ "gU", group = "Преобразовать в прописные", mode = { "n", "x", "o" } },
		{ "gq", group = "Форматировать текст", mode = { "n", "x", "o" } },

		-- Встроенные команды z.
		{ "zz", desc = "Поместить строку курсора по центру", mode = { "n", "x" } },
		{ "zt", desc = "Поместить строку курсора сверху", mode = { "n", "x" } },
		{ "zb", desc = "Поместить строку курсора снизу", mode = { "n", "x" } },
		{ "za", desc = "Переключить сворачивание", mode = "n" },
		{ "zA", desc = "Переключить сворачивание рекурсивно", mode = "n" },
		{ "zo", desc = "Раскрыть свёртку", mode = "n" },
		{ "zO", desc = "Раскрыть свёртку рекурсивно", mode = "n" },
		{ "zc", desc = "Закрыть свёртку", mode = "n" },
		{ "zC", desc = "Закрыть свёртку рекурсивно", mode = "n" },
		{ "zm", desc = "Увеличить уровень сворачивания", mode = "n" },
		{ "zM", desc = "Закрыть все свёртки", mode = "n" },
		{ "zr", desc = "Уменьшить уровень сворачивания", mode = "n" },
		{ "zR", desc = "Раскрыть все свёртки", mode = "n" },
		{ "zf", group = "Создать свёртку", mode = { "n", "x", "o" } },
		{ "zd", desc = "Удалить свёртку", mode = "n" },
		{ "zD", desc = "Удалить свёртку рекурсивно", mode = "n" },
		{ "zE", desc = "Удалить все свёртки", mode = "n" },
		{ "z=", desc = "Варианты исправления слова", mode = "n" },
		{ "zg", desc = "Добавить слово в словарь", mode = "n" },
		{ "zw", desc = "Пометить слово как ошибочное", mode = "n" },
		{ "zj", desc = "К началу следующей свёртки", mode = "n" },
		{ "zk", desc = "К концу предыдущей свёртки", mode = "n" },

		-- Парные переходы [ и ].
		{ "[d", desc = "К предыдущей диагностике", mode = "n" },
		{ "]d", desc = "К следующей диагностике", mode = "n" },
		{ "[p", desc = "Вставить с отступом перед курсором", mode = "n" },
		{ "]p", desc = "Вставить с отступом после курсора", mode = "n" },
		{ "[P", desc = "Вставить с отступом перед курсором", mode = "n" },
		{ "]P", desc = "Вставить с отступом после курсора", mode = "n" },
		{ "[c", desc = "К предыдущему изменению diff", mode = "n" },
		{ "]c", desc = "К следующему изменению diff", mode = "n" },
		{ "[s", desc = "К предыдущей орфографической ошибке", mode = "n" },
		{ "]s", desc = "К следующей орфографической ошибке", mode = "n" },
		{ "[z", desc = "К началу текущей свёртки", mode = "n" },
		{ "]z", desc = "К концу текущей свёртки", mode = "n" },
		{ "[[", desc = "К предыдущему разделу", mode = { "n", "x", "o" } },
		{ "]]", desc = "К следующему разделу", mode = { "n", "x", "o" } },
		{ "[]", desc = "К концу предыдущего раздела", mode = { "n", "x", "o" } },
		{ "][", desc = "К концу следующего раздела", mode = { "n", "x", "o" } },
		{
			"[{",
			desc = "К предыдущей непарной фигурной скобке",
			mode = { "n", "x", "o" },
		},
		{
			"]}",
			desc = "К следующей непарной фигурной скобке",
			mode = { "n", "x", "o" },
		},
		{
			"[(",
			desc = "К предыдущей непарной круглой скобке",
			mode = { "n", "x", "o" },
		},
		{ "])", desc = "К следующей непарной круглой скобке", mode = { "n", "x", "o" } },

		-- Окна Vim после <C-w>.
		{ "<C-w>h", desc = "Окно слева", mode = "n" },
		{ "<C-w>j", desc = "Окно снизу", mode = "n" },
		{ "<C-w>k", desc = "Окно сверху", mode = "n" },
		{ "<C-w>l", desc = "Окно справа", mode = "n" },
		{ "<C-w>w", desc = "Следующее окно", mode = "n" },
		{ "<C-w>W", desc = "Предыдущее окно", mode = "n" },
		{ "<C-w>p", desc = "Последнее активное окно", mode = "n" },
		{ "<C-w>s", desc = "Разделить горизонтально", mode = "n" },
		{ "<C-w>v", desc = "Разделить вертикально", mode = "n" },
		{ "<C-w>n", desc = "Создать новое окно", mode = "n" },
		{ "<C-w>c", desc = "Закрыть текущее окно", mode = "n" },
		{ "<C-w>o", desc = "Оставить только текущее окно", mode = "n" },
		{ "<C-w>=", desc = "Выровнять размеры окон", mode = "n" },
		{ "<C-w>+", desc = "Увеличить высоту", mode = "n" },
		{ "<C-w>-", desc = "Уменьшить высоту", mode = "n" },
		{ "<C-w>>", desc = "Увеличить ширину", mode = "n" },
		{ "<C-w><", desc = "Уменьшить ширину", mode = "n" },
		{ "<C-w>_", desc = "Максимальная высота", mode = "n" },
		{ "<C-w>|", desc = "Максимальная ширина", mode = "n" },
		{ "<C-w>r", desc = "Повернуть окна вниз или вправо", mode = "n" },
		{ "<C-w>R", desc = "Повернуть окна вверх или влево", mode = "n" },
		{ "<C-w>x", desc = "Обменять текущее и следующее окно", mode = "n" },
		{ "<C-w>H", desc = "Переместить окно влево", mode = "n" },
		{ "<C-w>J", desc = "Переместить окно вниз", mode = "n" },
		{ "<C-w>K", desc = "Переместить окно вверх", mode = "n" },
		{ "<C-w>L", desc = "Переместить окно вправо", mode = "n" },
		{ "<C-w>T", desc = "Переместить окно во вкладку", mode = "n" },
	})
end

local function register_text_objects(wk)
	wk.add({
		{
			"a",
			group = "Текстовый объект целиком",
			icon = icon("󰅩 ", "yellow"),
			mode = { "x", "o" },
		},
		{
			"i",
			group = "Содержимое текстового объекта",
			icon = icon("󰅩 ", "cyan"),
			mode = { "x", "o" },
		},

		{ "aw", desc = "Слово с окружающими пробелами", mode = { "x", "o" } },
		{ "iw", desc = "Слово", mode = { "x", "o" } },
		{ "aW", desc = "WORD с окружающими пробелами", mode = { "x", "o" } },
		{ "iW", desc = "WORD", mode = { "x", "o" } },
		{ "as", desc = "Предложение с окружающими пробелами", mode = { "x", "o" } },
		{ "is", desc = "Предложение", mode = { "x", "o" } },
		{ "ap", desc = "Абзац с окружающими пустыми строками", mode = { "x", "o" } },
		{ "ip", desc = "Абзац", mode = { "x", "o" } },
		{ "at", desc = "HTML/XML-тег целиком", mode = { "x", "o" } },
		{ "it", desc = "Содержимое HTML/XML-тега", mode = { "x", "o" } },
		{ 'a"', desc = "Двойные кавычки целиком", mode = { "x", "o" } },
		{ 'i"', desc = "Внутри двойных кавычек", mode = { "x", "o" } },
		{ "a'", desc = "Одинарные кавычки целиком", mode = { "x", "o" } },
		{ "i'", desc = "Внутри одинарных кавычек", mode = { "x", "o" } },
		{ "a`", desc = "Обратные кавычки целиком", mode = { "x", "o" } },
		{ "i`", desc = "Внутри обратных кавычек", mode = { "x", "o" } },
		{ "a(", desc = "Круглые скобки целиком", mode = { "x", "o" } },
		{ "i(", desc = "Внутри круглых скобок", mode = { "x", "o" } },
		{ "a[", desc = "Квадратные скобки целиком", mode = { "x", "o" } },
		{ "i[", desc = "Внутри квадратных скобок", mode = { "x", "o" } },
		{ "a{", desc = "Фигурные скобки целиком", mode = { "x", "o" } },
		{ "i{", desc = "Внутри фигурных скобок", mode = { "x", "o" } },
		{ "a<", desc = "Угловые скобки целиком", mode = { "x", "o" } },
		{ "i<", desc = "Внутри угловых скобок", mode = { "x", "o" } },
	})
end

local function register_insert_completion(wk)
	wk.add({
		{ "<C-x>", group = "Вставка и дополнение", icon = icon("󰘦 ", "green"), mode = "i" },
		{ "<C-x><C-l>", desc = "Дополнить целую строку", mode = "i" },
		{ "<C-x><C-n>", desc = "Дополнить слово из текущего файла", mode = "i" },
		{ "<C-x><C-k>", desc = "Дополнить слово из словаря", mode = "i" },
		{ "<C-x><C-t>", desc = "Дополнить слово из тезауруса", mode = "i" },
		{ "<C-x><C-i>", desc = "Дополнить слово из подключённых файлов", mode = "i" },
		{ "<C-x><C-]>", desc = "Дополнить тег", mode = "i" },
		{ "<C-x><C-f>", desc = "Дополнить путь к файлу", mode = "i" },
		{ "<C-x><C-d>", desc = "Дополнить определение или макрос", mode = "i" },
		{ "<C-x><C-v>", desc = "Дополнить команду Vim", mode = "i" },
		{ "<C-x><C-u>", desc = "Пользовательское дополнение", mode = "i" },
		{ "<C-x><C-o>", desc = "Omni-дополнение", mode = "i" },
		{ "<C-x>s", desc = "Исправить орфографию", mode = "i" },
		{
			"<C-r>",
			group = "Вставить из регистра",
			icon = icon("󰅍 ", "yellow"),
			mode = { "i", "c" },
		},
	})
end

function M.register()
	local wk = require("which-key")

	register_main_groups(wk)
	register_custom_mappings(wk)
	register_native_prefixes(wk)
	register_text_objects(wk)
	register_insert_completion(wk)
end

return M
