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
				executable = "latexmk",

				-- Для main.tex побочные файлы попадут в .latex/main/
				aux_dir = function(file_info)
					local name = vim.fn.fnamemodify(file_info.target_basename, ":t:r")
					return ".latex/" .. name
				end,

				options = {
					"-lualatex",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
					"-shell-escape",
				},
			}

			-- Удобные переключатели для окружений и разделителей
			vim.g.vimtex_env_toggle_map = { itemize = "enumerate", enumerate = "itemize" }
			vim.g.vimtex_delim_toggle_mod_list = { { "\\left", "\\right" }, { "\\big", "\\big" } }

			-- Горячая клавиша для компиляции
			vim.keymap.set(
				"n",
				"<leader>LL",
				"<cmd>VimtexCompile<CR>",
				{ desc = "Собрать LaTeX-документ" }
			)
		end,
	},
	-- For `plugins/markview.lua` users.
}
