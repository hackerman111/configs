return {
	-- Поддержка LaTeX
	-- Поддержка LaTeX
	{
		"lervag/vimtex",
		init = function()
			-- Настройка просмотрщика и быстрого исправления ошибок
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_quickfix_mode = 0

			-- Настраиваем компилятор latexmk для работы с преамбулой
			vim.g.vimtex_compiler_latexmk = {
				-- Используем latexmk как основной инструмент для сборки
				executable = "latexmk",

				options = {
					-- ВАЖНО: Преамбула уровня 290 требует LuaLaTeX или XeLaTeX.
					-- Эта строка автоматически выберет lualatex, если он доступен, иначе xelatex.
					"-lualatex",

					-- Стандартные опции для удобной работы и отладки
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",

					-- Разрешает LaTeX выполнять внешние команды. Необходимо для пакетов
					-- вроде 'minted' (подсветка кода) или сложных импортов.
					"-shell-escape",
				},
			}

			-- Удобные переключатели для окружений и разделителей
			vim.g.vimtex_env_toggle_map = { itemize = "enumerate", enumerate = "itemize" }
			vim.g.vimtex_delim_toggle_mod_list = { { "\\left", "\\right" }, { "\\big", "\\big" } }

			-- Горячая клавиша для компиляции
			vim.keymap.set("n", "<leader>LL", "<cmd>VimtexCompile<CR>", { desc = "Compile LaTeX" })
		end,
	},
	-- Сниппеты
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip").config.set_config({
				enable_autosnippets = true,
				store_selection_keys = "<Tab>",
				vim.cmd([[
    imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
    smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
    imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]),
			})
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
		end,
	},
	-- For `plugins/markview.lua` users.
	{
		"OXY2DEV/markview.nvim",
		lazy = false,

		dependencies = {
			"saghen/blink.cmp",
		},
		opts = {
			experimental = {
				check_rtp_messag = false,
			},
		},
	},
}
