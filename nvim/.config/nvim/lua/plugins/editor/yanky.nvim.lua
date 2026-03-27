return {
	"gbprod/yanky.nvim",
	dependencies = {
		{ "kkharji/sqlite.lua" },
	},
	opts = {
		ring = { storage = "sqlite" },
	},
	keys = {
		{
			"<leader>p",
			"<cmd>YankyRingHistory<cr>",
			mode = { "n", "x" },
			desc = "Открыть историю копирования",
		},
		{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Скопировать текст" },
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Вставить после курсора" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Вставить перед курсором" },
		{
			"gp",
			"<Plug>(YankyGPutAfter)",
			mode = { "n", "x" },
			desc = "Вставить после выделения",
		},
		{
			"gP",
			"<Plug>(YankyGPutBefore)",
			mode = { "n", "x" },
			desc = "Вставить перед выделением",
		},
		{ "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Предыдущая запись в истории" },
		{ "<c-n>", "<Plug>(YankyNextEntry)", desc = "Следующая запись в истории" },
		{
			"]p",
			"<Plug>(YankyPutIndentAfterLinewise)",
			desc = "Вставить со смещением после курсора (построчно)",
		},
		{
			"[p",
			"<Plug>(YankyPutIndentBeforeLinewise)",
			desc = "Вставить со смещением перед курсором (построчно)",
		},
		{
			"]P",
			"<Plug>(YankyPutIndentAfterLinewise)",
			desc = "Вставить со смещением после курсора (построчно)",
		},
		{
			"[P",
			"<Plug>(YankyPutIndentBeforeLinewise)",
			desc = "Вставить со смещением перед курсором (построчно)",
		},
		{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Вставить и сместить вправо" },
		{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Вставить и сместить влево" },
		{
			">P",
			"<Plug>(YankyPutIndentBeforeShiftRight)",
			desc = "Вставить перед и сместить вправо",
		},
		{
			"<P",
			"<Plug>(YankyPutIndentBeforeShiftLeft)",
			desc = "Вставить перед и сместить влево",
		},
		{
			"=p",
			"<Plug>(YankyPutAfterFilter)",
			desc = "Вставить после применения фильтра",
		},
		{
			"=P",
			"<Plug>(YankyPutBeforeFilter)",
			desc = "Вставить перед применением фильтра",
		},
		},
		config = function()
			require("yanky").setup({
				ring = {
					history_length = 100,
					storage = "shada",
					storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db", -- Only for sqlite storage
					sync_with_numbered_registers = true,
					cancel_event = "update",
					ignore_registers = { "_" },
				update_register_on_cycle = false,
				permanent_wrapper = nil,
			},
			picker = {
				select = {
					action = nil, -- nil to use default put action
				},
				telescope = {
					use_default_mappings = true, -- if default mappings should be used
					mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
				},
			},
			system_clipboard = {
				sync_with_ring = true,
				clipboard_register = nil,
			},
			highlight = {
				on_put = true,
				on_yank = true,
				timer = 500,
			},
				preserve_cursor_position = {
					enabled = true,
				},
				textobj = {
					enabled = false,
				},
			})
		end,
	}
