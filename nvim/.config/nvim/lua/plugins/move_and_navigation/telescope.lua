-- plugins/telescope.lua:

return {
	-- 1. Основная конфигурация Telescope и его расширений
	{
		"nvim-telescope/telescope.nvim",
		version = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"jvgrootveld/telescope-zoxide",
			-- Убедитесь, что frecency здесь, он нужен для поиска по частоте
			{
				"nvim-telescope/telescope-frecency.nvim",
				dependencies = { "kkharji/sqlite.lua" }, -- frecency требует sqlite
			},
			"fdschmidt93/telescope-egrepify.nvim",
			"cljoly/telescope-repo.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")
			local egrep_actions = require("telescope._extensions.egrepify.actions")

			-- НАСТРОЙКА TELESCOPE
			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["<C-b>"] = function(prompt_bufnr)
								local selection = require("telescope.actions.state").get_selected_entry()
								require("telescope.actions").close(prompt_bufnr)
								require("telescope").extensions.file_browser.file_browser({
									path = selection.path,
									cwd = selection.path,
									attach_mappings = true,
								})
							end,
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},

					zoxide = {
						prompt_title = "[ Поиск по Zoxide ]",
					},

					-- Настройка для frecency (можно указать свой воркспейс)
					frecency = {
						-- auto_validate = false, -- можно отключить проверку существования файлов для скорости
						show_scores = true,
						workspaces = {
							["dotfiles"] = "~/.dotfiles",
							["nvim"] = "~/.config/nvim",
						},
					},
					repo = {
						list = {
							search_dirs = {
								"~/AMI",
								"~/.config/nvim",
							},
						},
					},
					egrepify = {
						-- intersect tokens in prompt ala "str1.*str2" that ONLY matches
						-- if str1 and str2 are consecutively in line with anything in between (wildcard)
						AND = true, -- default
						permutations = false, -- opt-in to imply AND & match all permutations of prompt tokens
						lnum = true, -- default, not required
						lnum_hl = "EgrepifyLnum", -- default, not required, links to `Constant`
						col = false, -- default, not required
						col_hl = "EgrepifyCol", -- default, not required, links to `Constant`
						title = true, -- default, not required, show filename as title rather than inline
						filename_hl = "EgrepifyFile", -- default, not required, links to `Title`
						results_ts_hl = true, -- set to false if you experience latency issues!
						{
							["#"] = {
								-- #$REMAINDER
								-- # is caught prefix
								-- `input` becomes $REMAINDER
								-- in the above example #lua,md -> input: lua,md
								flag = "glob",
								cb = function(input)
									return string.format([[*.{%s}]], input)
								end,
							},
							-- filter for (partial) folder names
							-- example prompt: >conf $MY_PROMPT
							-- searches with ripgrep prompt $MY_PROMPT in paths that have "conf" in folder
							-- i.e. rg --glob="**/conf*/**" -- $MY_PROMPT
							[">"] = {
								flag = "glob",
								cb = function(input)
									return string.format([[**/{%s}*/**]], input)
								end,
							},
							-- filter for (partial) file names
							-- example prompt: &egrep $MY_PROMPT
							-- searches with ripgrep prompt $MY_PROMPT in paths that have "egrep" in file name
							-- i.e. rg --glob="*egrep*" -- $MY_PROMPT
							["&"] = {
								flag = "glob",
								cb = function(input)
									return string.format([[*{%s}*]], input)
								end,
							},
						},
						file_browser = {
							theme = "ivy",
							hijack_netrw = true,
							mappings = {
								["i"] = {
									-- your custom insert mode mappings
								},
								["n"] = {
									-- your custom normal mode mappings
								},
								["<C-b>"] = {
									keepinsert = true,
									action = function(selection)
										require("telescope").extensions.file_browser.file_browser({
											cwd = selection.path,
										})
									end,
								},
							},
						},
						-- default mappings
						mappings = {
							i = {
								-- toggle prefixes, prefixes is default
								["<C-z>"] = egrep_actions.toggle_prefixes,
								-- toggle AND, AND is default, AND matches tokens and any chars in between
								["<C-a>"] = egrep_actions.toggle_and,
								-- toggle permutations, permutations of tokens is opt-in
								["<C-r>"] = egrep_actions.toggle_permutations,
							},
						},
					},
				},
			})

			-- Загрузка расширений
			telescope.load_extension("ui-select")
			telescope.load_extension("zoxide")
			telescope.load_extension("file_browser")
			telescope.load_extension("frecency")
			telescope.load_extension("egrepify")
			telescope.load_extension("repo")

			-- ВАШИ КЕЙМАПЫ
			vim.keymap.set("n", "<space>fd", function()
				require("telescope").extensions.file_browser.file_browser()
			end, { desc = "Открыть файловый браузер" })
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files()
			end, { desc = "Найти файлы" })
			vim.keymap.set("n", "<leader>fp", function()
				telescope.extensions.frecency.frecency()
			end, { desc = "Найти файлы (по частоте)" })

			-- Остальные кеймапы без изменений
			vim.keymap.set("n", "<leader>fc", function()
				builtin.find_files({ cwd = "~/" })
			end, { desc = "Найти файлы в компьютере" })
			vim.keymap.set("n", "<leader>fg", function()
				telescope.extensions.egrepify.egrepify({})
			end, { desc = "Найти по содержимому" })
			vim.keymap.set(
				"n",
				"<leader>fb",
				builtin.buffers,
				{ desc = "Найти в открытых буферах" }
			)
			vim.keymap.set(
				"n",
				"<leader>fo",
				builtin.oldfiles,
				{ desc = "Найти в недавних файлах" }
			)

			vim.keymap.set("n", "<leader>fe", function()
				builtin.diagnostics({ bufnr = 0 })
			end, { desc = "Найти ошибки в файле" })

			-- Кеймапы для команд Telescope
			-- ИСПРАВЛЕНО: Заменен <cmd> на прямой вызов функции для стабильности
			vim.keymap.set("n", "<leader>fz", function()
				require("telescope").extensions.zoxide.list()
			end, { desc = "Поиск по Zoxide" })

			vim.keymap.set(
				"n",
				"<leader>fr",
				"<cmd>Telescope repo list <cr>",
				{ desc = "Поиск по проектам" }
			)
		end,
	},
}
