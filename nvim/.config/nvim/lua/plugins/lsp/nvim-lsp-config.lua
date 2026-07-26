-- ~/.config/nvim/lua/plugins/lsp_and_lang.lua
-- Плагины для LSP, автодополнения и поддержки языков

return {
	-- Автодополнение и LSP
	-- Подсветка синтаксиса

	{
		lazy = false, -- REQUIRED: tell lazy.nvim to start this plugin at startup
		"neovim/nvim-lspconfig",

		dependencies = {
			"saghen/blink.cmp",

			{
				"mason-org/mason.nvim",
				opts = {},
			},

			{
				"mason-org/mason-lspconfig.nvim",
				opts = {
					-- Список серверов явно включается через config.lsp.
					-- Не запускаем прочие установленные в Mason серверы автоматически.
					automatic_enable = false,
					ensure_installed = {
						"lua_ls",
						"pyright",
						"ruff",
						"clangd",
						"rust_analyzer",
						"texlab",
						"marksman",
					},
				},
			},
		},

		config = function()
			require("config.lsp").setup()
		end,
	},

	-- Поддержка CMake
	{ "cdelledonne/vim-cmake" },
}
