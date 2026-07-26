return {
	"ray-x/lsp_signature.nvim",

	event = "InsertEnter",

	opts = {
		bind = true,

		-- Не показывать docstring.
		doc_lines = 0,

		max_width = 76,
		max_height = 5,
		wrap = true,

		floating_window = true,

		-- Располагать там, где больше свободного места.
		floating_window_above_cur_line = true,

		-- Не добавлять virtual text возле строки.
		hint_enable = false,

		-- Автоматически закрыть после завершения ввода аргументов.
		close_timeout = 1500,
		auto_close_after = nil,

		-- Переключение между перегрузками.
		select_signature_key = "<M-n>",

		-- Открыть или закрыть окно вручную.
		toggle_key = "<C-k>",

		hi_parameter = "IncSearch",

		handler_opts = {
			border = "rounded",
		},
	},
}
