local M = {}

M.opts = {
	preset = "classic",
	delay = function(ctx)
		return ctx.plugin and 0 or 200
	end,
	filter = function()
		return true
	end,
	spec = {},
	notify = true,
	triggers = {
		{ "<auto>", mode = "nxso" },
	},
	defer = function(ctx)
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
		padding = { 1, 2 },
		title = true,
		title_pos = "center",
		zindex = 1000,
		bo = {},
		wo = {},
	},
	layout = {
		width = { min = 20 },
		spacing = 3,
	},
	keys = {
		scroll_down = "<c-d>",
		scroll_up = "<c-u>",
	},
	sort = { "local", "order", "group", "alphanum", "mod" },
	expand = 0,
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
		breadcrumb = "»",
		separator = "➜",
		group = "+",
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
			BS = "󰁮",
			Space = "󱁐 ",
			Tab = "󰌒 ",
			F1 = "󱊫",
			F2 = "󱊬",
			F3 = "󱊭",
			F4 = "󱊮",
			F5 = "󱊯",
			F6 = "󱊰",
			F7 = "󱊱",
			F8 = "󱊲",
			F9 = "󱊳",
			F10 = "󱊴",
			F11 = "󱊵",
			F12 = "󱊶",
		},
	},
	show_help = true,
	show_keys = true,
	disable = {
		ft = {},
		bt = {},
	},
	debug = false,
}

function M.register()
	local wk = require("which-key")

	wk.add({
		{ "<leader>a", group = "Агенты и терминал" },
		{ "<leader>c", group = "Код" },
		{ "<leader>d", group = "Отладка" },
		{ "<leader>f", group = "Файлы и поиск" },
		{ "<leader>g", group = "Git, форматирование и lint" },
		{ "<leader>h", group = "Harpoon" },
		{ "<leader>l", group = "LSP и структура" },
		{ "<leader>L", group = "LaTeX" },
		{ "<leader>r", group = "Переименование" },
		{ "<leader>s", group = "Поиск и замена" },
		{ "<leader>t", group = "Проблемы и символы" },
		{ "<leader>w", group = "Окна" },
		{ "ga", group = "Регистр текста" },
		{ "<Tab>", desc = "Следующая вкладка" },
		{ "<S-Tab>", desc = "Предыдущая вкладка" },
		{ "<F4>", desc = "Отладка: шаг через" },
		{ "<F12>", desc = "Терминал: открыть или закрыть" },
	})

	wk.add({
		{ "g", group = "Операции с выделением", mode = "x" },
		{ "ga", group = "Регистр текста", mode = "x" },
		{ "gr", group = "LSP", mode = "x" },
		{ "a", group = "Текстовые объекты вокруг", mode = "x" },
		{ "i", group = "Текстовые объекты внутри", mode = "x" },
		{ "z", group = "Положение окна", mode = "x" },
		{ "<Tab>", desc = "LuaSnip: сохранить выделение", mode = "x" },
		{ "#", desc = "Искать выделение назад", mode = "x" },
		{ "*", desc = "Искать выделение вперед", mode = "x" },
		{ "@", desc = "Выполнить макрос по строкам выделения", mode = "x" },
		{
			"Q",
			desc = "Повторить последний макрос по строкам выделения",
			mode = "x",
		},
		{ "S", desc = "Flash: выделение по структуре", mode = "x" },
		{ "R", desc = "Flash: поиск по структуре", mode = "x" },
		{ "[%", desc = "К предыдущему непарному блоку", mode = "x" },
		{ "]%", desc = "К следующему непарному блоку", mode = "x" },
		{ "a%", desc = "Выделить парный блок", mode = "x" },
		{ "g%", desc = "К предыдущему парному блоку", mode = "x" },
		{ "gb", desc = "Закомментировать блоком", mode = "x" },
		{ "gc", desc = "Закомментировать построчно", mode = "x" },
		{ "gra", desc = "Действия с кодом", mode = "x" },
		{ "gx", desc = "Открыть выделенное внешней программой", mode = "x" },
		{ "zb", desc = "Строка курсора внизу окна", mode = "x" },
		{ "zz", desc = "Строка курсора по центру окна", mode = "x" },
		{ "zt", desc = "Строка курсора вверху окна", mode = "x" },
		{ "<C-E>", desc = "Прокрутить окно вниз", mode = "x" },
		{ "<C-Y>", desc = "Прокрутить окно вверх", mode = "x" },
		{ "<C-F>", desc = "Прокрутить на страницу вниз", mode = "x" },
		{ "<C-B>", desc = "Прокрутить на страницу вверх", mode = "x" },
		{ "<C-D>", desc = "Прокрутить на полстраницы вниз", mode = "x" },
		{ "<C-U>", desc = "Прокрутить на полстраницы вверх", mode = "x" },
	})
end

return M
