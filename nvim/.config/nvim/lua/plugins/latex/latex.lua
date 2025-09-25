return {
	-- Поддержка LaTeX
	{
		"lervag/vimtex",
		init = function()
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_compiler_latexmk = {
				executable = "latexmk",
				options = { "-xelatex", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
			}
			vim.g.vimtex_env_toggle_map = { itemize = "enumerate", enumerate = "itemize" }
			vim.g.vimtex_delim_toggle_mod_list = { { "\\left", "\\right" }, { "\\big", "\\big" } }
		end,
	},
	-- Сниппеты
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			-- Somewhere in your Neovim startup, e.g. init.lua
			require("luasnip").config.set_config({ -- Setting LuaSnip config
				enable_autosnippets = true,
				store_selection_keys = "<Tab>",
			})
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
		end,
	},
}
