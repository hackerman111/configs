return {
	"stevearc/aerial.nvim",

	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	opts = {
		backends = {
			"lsp",
			"treesitter",
			"markdown",
			"man",
		},

		-- Боковую панель Aerial автоматически не открываем.
		open_automatic = false,

		-- Оставляем только структурные символы.
		filter_kind = {
			"Class",
			"Constructor",
			"Enum",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Struct",
			"Trait",
		},
	},
}
