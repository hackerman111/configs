-- plugins/telescope.lua:

return {
	-- 1. Основная конфигурация Telescope и его расширений
	{
		"nvim-telescope/telescope.nvim",
		version = "0.1.x",
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

			local function flash(prompt_bufnr)
				require("flash").jump({
					pattern = "^",
					label = { after = { 0, 0 } },
					search = {
						mode = "search",
						exclude = {
							function(win)
								return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
							end,
						},
					},
					action = function(match)
						local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
						picker:set_selection(match.pos[1] - 1)
					end,
				})
			end

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
						n = { s = flash },
					},
					initial_mode = "normal",
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

						extensions = {
							aerial = {
								-- Показывать только иконку и название символа,
								-- без строки исходного кода справа.
								show_columns = "symbols",

								col1_width = 3,
								col2_width = 50,

								format_symbol = function(symbol_path)
									local depth = #symbol_path - 1
									local name = symbol_path[#symbol_path]

									if depth == 0 then
										return name
									end

									return string.rep("  ", depth - 1) .. "├─ " .. name
								end,
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
			telescope.load_extension("aerial")

			local function telescope_outline()
				telescope.extensions.aerial.aerial({
					prompt_title = "Outline",

					initial_mode = "normal",
					sorting_strategy = "ascending",

					layout_strategy = "vertical",

					layout_config = {
						width = 0.65,
						height = 0.80,
						prompt_position = "top",
						preview_height = 0.45,
					},
				})
			end

			vim.keymap.set("n", "<leader>o", telescope_outline, {
				desc = "Outline текущего файла",
			})

			-- ВАШИ КЕЙМАПЫ
			vim.keymap.set("n", "<space>fd", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
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

			vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "показать марки" })

			vim.keymap.set("n", "<leader>fe", function()
				builtin.diagnostics({ bufnr = 0 })
			end, { desc = "Найти ошибки в файле" })

			vim.keymap.set(
				"n",
				"<leader>fr",
				"<cmd>Telescope repo list <cr>",
				{ desc = "Поиск по проектам" }
			)
		end,
	},
}
