-- lua/plugins/lspsaga.lua
return {
	"nvimdev/lspsaga.nvim",
	event = { "LspAttach", "BufReadPre", "BufNewFile" }, -- Ленивая загрузка при подключении LSP и чтении/создании буфера
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Поддержка иконок
		"nvim-lua/plenary.nvim", -- Асинхронные утилиты
		"rcarriga/nvim-notify", -- Дополнительно: анимированные уведомления
	},
	config = function()
		local saga = require("lspsaga")
		saga.setup({
			ui = {
				border = "rounded",
				theme = "auto",
				title = true,
				finder = " ",
				definition = "📖 ",
				code_action = "💡",
				separator = " > ",
			},

			lightbulb = {
				enable = true,
				sign = true,
				sign_priority = 40,
				virtual_text = true,
				virtual_text_priority = 100,
			},

			preview = {
				lines_above = 2,
				lines_below = 8,
			},
			max_preview_width = 0.8,
			max_preview_height = 0.6,

			finder = {
				max_height = 0.7,
				left_width = 0.3, -- Ширина левой панели
				right_width = 0.3, -- Ширина правой панели
				default = "ref+imp+def+ds", -- По умолчанию показываем ссылки, имплементации, определения и символы документа
				methods = { ds = "textDocument/documentSymbol" }, -- 'ds' для поиска символов в документе
				layout = "float",
				filter = {},
				silent = false,
				keys = {
					split = "o", -- Горизонтальный сплит
					vsplit = "s", -- Вертикальный сплит
					tabe = "t", -- Новая вкладка
					quit = { "q", "<ESC>" },
				},
			},

			definition = {
				width = 0.6,
				height = 0.5,
				keys = {
					edit = "<CR>",
					vsplit = "s",
					split = "i",
					tabe = "t",
					quit = "q",
				},
			},

			references = { max_height = 0.7 },

			diagnostic = {
				show_code_action = true,
				on_insert = false,
				on_insert_follow = false,
				insert_winblend = 25,
				error = " ",
				warn = " ",
				info = " ",
				hint = " ",
				keys = { expand = "gl" },
			},

			rename = {
				quit = "<C-c>",
				exec = "<CR>",
				view = "v",
			},

			callhierarchy = {
				show_detail = "d",
				edit = "e",
				vsplit = "s",
				split = "i",
				tabe = "t",
				quit = "q",
			},

			symbol_in_winbar = {
				enable = true,
				separator = " › ",
				hide_keyword = true,
				color_mode = true,
			},

			term = { enable = false },

			outline = {
				win_position = "right",
				win_with = "editor",
				win_width = 40,
				auto_close = true,
				show_detail = true,
				keys = {
					jump = "<CR>",
					expand = "l",
					collapse = "h",
					quit = "q",
				},
			},
		})

		-- Настройка горячих клавиш
		local map = vim.keymap.set
		local opts = { silent = true, noremap = true }
		local telescope = require("telescope.builtin")

		map(
			"n",
			"K",
			"<cmd>Lspsaga hover_doc<CR>",
			vim.tbl_extend("force", opts, { desc = "Показать документацию (Hover)" })
		)
		map(
			"n",
			"gd",
			"<cmd>Lspsaga goto_definition<CR>",
			vim.tbl_extend("force", opts, { desc = "Перейти к определению" })
		)
		map(
			"n",
			"gD",
			"<cmd>Lspsaga goto_type_definition<CR>",
			vim.tbl_extend("force", opts, { desc = "Перейти к определению типа" })
		)

		map(
			"n",
			"[d",
			"<cmd>Lspsaga diagnostic_jump_prev<CR>",
			vim.tbl_extend("force", opts, { desc = "К предыдущей диагностике" })
		)
		map(
			"n",
			"]d",
			"<cmd>Lspsaga diagnostic_jump_next<CR>",
			vim.tbl_extend("force", opts, { desc = "К следующей диагностике" })
		)
		map(
			"n",
			"<leader>gD",
			"<cmd>Lspsaga show_line_diagnostics<CR>",
			vim.tbl_extend("force", opts, { desc = "Показать диагностику строки" })
		)

		map(
			{ "n", "v" },
			"<leader>ca",
			"<cmd>Lspsaga code_action<CR>",
			vim.tbl_extend("force", opts, { desc = "Действия с кодом (Code Action)" })
		)

		map(
			"n",
			"<leader>o",
			"<cmd>Lspsaga outline<CR>",
			vim.tbl_extend("force", opts, { desc = "Структура файла (Outline)" })
		)

		-- Интеграция с notify для уведомлений
		vim.notify = require("notify")
	end,
}
