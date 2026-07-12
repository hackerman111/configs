return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	keys = {
		{ "-", "<CMD>Oil<CR>", desc = "Открыть родительскую директорию" },
	},
	opts = {
		default_file_explorer = true,
		columns = {
			"icon",
		},
		buf_options = {
			buflisted = false,
			bufhidden = "hide",
		},
		win_options = {
			wrap = false,
			signcolumn = "no",
			cursorcolumn = false,
			foldcolumn = "0",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "nvic",
		},
		delete_to_trash = false,
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		cleanup_delay_ms = 2000,
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = false,
		},
		constrain_cursor = "editable",
		watch_for_changes = false,
		keymaps = {
			["g?"] = { "actions.show_help", mode = "n", desc = "Oil: показать справку" },
			["<CR>"] = { "actions.select", desc = "Oil: открыть файл или каталог" },
			["s"] = false,
			["v"] = false,
			["t"] = false,
			["gp"] = {
				"actions.paste_from_system_clipboard",
				opts = { delete_original = true },
				desc = "Oil: переместить сюда из буфера обмена",
			},
			["<C-p>"] = false,
			["<C-c>"] = { "actions.close", mode = "n", desc = "Oil: закрыть" },
			["gr"] = { "actions.refresh", desc = "Oil: обновить список" },
			["-"] = { "actions.parent", mode = "n", desc = "Oil: подняться на уровень выше" },
			["_"] = {
				"actions.open_cwd",
				mode = "n",
				desc = "Oil: открыть текущую рабочую директорию",
			},
			["`"] = { "actions.cd", mode = "n", desc = "Oil: сделать директорию текущей" },
			["~"] = {
				"actions.cd",
				opts = { scope = "tab" },
				mode = "n",
				desc = "Oil: сделать директорию текущей для вкладки",
			},
			["gs"] = { "actions.change_sort", mode = "n", desc = "Oil: изменить сортировку" },
			["gx"] = { "actions.open_external", desc = "Oil: открыть внешней программой" },
			["g."] = {
				"actions.toggle_hidden",
				mode = "n",
				desc = "Oil: показать или скрыть скрытые файлы",
			},
			["g\\"] = { "actions.toggle_trash", mode = "n", desc = "Oil: переключить корзину" },
		},
		use_default_keymaps = true,
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name)
				return name:match("^%.") ~= nil
			end,
			is_always_hidden = function()
				return false
			end,
			natural_order = "fast",
			case_insensitive = false,
			sort = {
				{ "type", "asc" },
				{ "name", "asc" },
			},
			highlight_filename = function()
				return nil
			end,
		},
		extra_scp_args = {},
		git = {
			add = function()
				return false
			end,
			mv = function()
				return false
			end,
			rm = function()
				return false
			end,
		},
		float = {
			padding = 2,
			max_width = 0,
			max_height = 0,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			get_win_title = nil,
			preview_split = "auto",
			override = function(conf)
				return conf
			end,
		},
		preview_win = {
			update_on_cursor_moved = false,
			preview_method = "fast_scratch",
			disable_preview = function()
				return true
			end,
			win_options = {},
		},
		confirmation = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = 0.9,
			min_height = { 5, 0.1 },
			height = nil,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
		},
		progress = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = { 10, 0.9 },
			min_height = { 5, 0.1 },
			height = nil,
			border = "rounded",
			minimized_border = "none",
			win_options = {
				winblend = 0,
			},
		},
		ssh = {
			border = "rounded",
		},
		keymaps_help = {
			border = "rounded",
		},
	},
}
