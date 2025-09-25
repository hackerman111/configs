-- ~/.config/nvim/lua/plugins/lsp_and_lang.lua
-- Плагины для LSP, автодополнения и поддержки языков

return {
	-- Автодополнение и LSP
	-- Подсветка синтаксиса

	{
		"mason-org/mason.nvim",
		opts = {},
	},

	{

		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "pyright", "lua_ls", "ruff" },
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim" },
			{ "saghen/blink.cmp" },
		},
		opts = {
			servers = {
				lua_ls = {},
				rust_analyzer = {},
			},
		},
		-- The fix is to move the autocommand into the `config` function
		config = function(_, opts)
			require("lspconfig.ui.windows").default_options.border = "rounded"

			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},

	-- Поддержка CMake
	{ "cdelledonne/vim-cmake" },
}
