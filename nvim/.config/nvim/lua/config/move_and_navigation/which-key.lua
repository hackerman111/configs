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
	require("which-key").add({
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
end

return M
