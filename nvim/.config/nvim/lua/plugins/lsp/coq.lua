local is_coq_v2 = vim.fn.has("nvim-0.12") == 1

return {
	{
		"ms-jpq/coq_nvim",
		branch = "coq",
		lazy = false,

		init = function()
			local clients = {
				-- В blink это главный источник.
				lsp = {
					enabled = true,
					short_name = "lsp",
					weight_adjust = 0,
				},

				-- Твой blink использует cwd текущего файла,
				-- поэтому "file" здесь ближе, чем {"cwd", "file"}.
				paths = {
					enabled = true,
					short_name = "Path",
					resolution = { "file" },
					weight_adjust = 0,
				},

				-- В твоём blink.lua эти источники не используются.
				buffers = {
					enabled = false,
					short_name = "buf",

					-- Не предлагать слова из Markdown/Python внутри Rust и т.п.
					same_filetype = true,

					-- Полезный fallback, но ниже LSP/Tree-sitter/tags.
					weight_adjust = -0.6,

					always_on_top = false,
				},

				registers = {
					enabled = false,
					short_name = "reg",

					-- Последний yank. Этого обычно достаточно.
					-- Если добавить a-z, completion быстро становится шумным.
					words = { "0" },

					-- Не предлагать целые строки из registers.
					lines = {},

					weight_adjust = -1.4,
					always_on_top = false,
				},

				snippets = {
					-- Оставляем выключенным:
					-- у тебя snippets уже отдельно обрабатывает LuaSnip.
					enabled = false,
				},

				tags = {
					enabled = true,
					short_name = "tag",

					-- Хорошо работает для project-wide символов,
					-- особенно C/C++/Rust/Lua.
					weight_adjust = 0.15,

					always_on_top = false,

					parent_scope = " ← ",
					path_sep = " / ",
				},

				tmux = {
					enabled = false,
					short_name = "tmux",

					-- Вытаскивать слова только из текущей tmux-сессии.
					-- Иначе легко получить мусор из shell/logs другого проекта.
					all_sessions = false,

					-- Это скорее удобный fallback для команд,
					-- путей, имён переменных и текста из соседней pane.
					weight_adjust = -1.2,

					always_on_top = false,

					parent_scope = " ← ",
					path_sep = " / ",
				},

				tree_sitter = {
					enabled = true,
					short_name = "ts",

					-- Полезнее обычного buffer completion:
					-- знает синтаксический контекст текущего файла.
					weight_adjust = 0.35,

					always_on_top = false,

					path_sep = " ← ",
				},

				third_party = {
					enabled = false,
				},
			}

			-- В COQ v1 можно ограничивать каждый source отдельно.
			-- В v2 max_pulls удалён, поэтому ограничиваем общий список ниже.
			if not is_coq_v2 then
				clients.lsp.max_pulls = 28
				clients.paths.max_pulls = 5
			end

			vim.g.coq_settings = {
				completion = {
					-- Аналог постоянного Blink completion без <C-Space>.
					always = true,
					sticky_manual = true,
					skip_after = { " ", ":", "{", "}", "[", "]" },
				},

				keymap = {
					-- Критично.
					-- Иначе COQ заберёт Tab/S-Tab у твоего LuaSnip.
					recommended = false,

					-- Blink:
					-- preselect = true
					-- auto_insert = true
					pre_select = true,

					manual_complete = "<C-Space>",
					manual_complete_insertion_only = true,

					-- У COQ по умолчанию это <C-k>.
					-- У тебя <C-k> принадлежит lsp_signature.nvim.
					-- Убираем реальную клавишу, оставляя внутренний mapping.
					bigger_preview = "<Plug>(coq-preview)",
				},

				clients = clients,

				display = {
					ghost_text = {
						enabled = false,
					},

					preview = {
						enabled = false,
						border = "single",

						-- Сначала пытаемся открыть справа/слева,
						-- если места нет — сверху/снизу.
						positions = {
							east = 1,
							west = 2,
							north = 3,
							south = 4,
						},

						x_max_len = 88,

						-- Дать LSP чуть больше времени на
						-- completionItem/resolve с документацией.
						resolve_timeout = 0.25,
					},

					icons = {
						mode = "long",
						spacing = 1,
					},

					pum = {
						source_context = { "", "" },
					},
				},

				match = {
					-- 28 LSP + 5 Path из твоего blink.lua.
					max_results = 8,

					exact_matches = 2,
					fuzzy_cutoff = 0.6,
				},
			}

			-- Blink по умолчанию показывает примерно такой размер меню.
			-- В COQ v2 ограничение делается native Neovim option.
			vim.o.pumheight = 35
		end,

		config = function()
			local coq = require("coq")

			-- Полностью отключать COQ в TeX-буферах.
			local function update_coq_for_buffer(buf)
				local ft = vim.bo[buf].filetype
				local enabled = ft ~= "tex" and ft ~= "plaintex"

				local toggle = require("coq.lib.producers.toggle")

				-- В нашей конфигурации COQ используются только эти два source.
				toggle.set("lsp", enabled)
				toggle.set("paths", enabled)

				-- Если перешли в TeX с уже открытым completion menu,
				-- сразу закрываем его.
				if not enabled and vim.fn.pumvisible() == 1 then
					vim.api.nvim_feedkeys(vim.keycode("<C-e>"), "n", false)
				end
			end

			local coq_filetype_group = vim.api.nvim_create_augroup("user-coq-filetypes", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
				group = coq_filetype_group,
				callback = function(args)
					update_coq_for_buffer(args.buf)
				end,
			})

			-- На случай, если Neovim уже стартовал внутри открытого файла.
			update_coq_for_buffer(vim.api.nvim_get_current_buf())

			-- COQ v2, Nvim >= 0.12.
			if coq.setup then
				coq.setup()
			else
				-- COQ v1 fallback для Nvim 0.11.
				coq.Now("--shut-up")
			end

			-- COQ добавляет noinsert, а у тебя Blink:
			--
			-- preselect = true
			-- auto_insert = true
			--
			-- Поэтому возвращаем Blink-поведение.

			local group = vim.api.nvim_create_augroup("user-coq-blink-ux", { clear = true })

			-- Blink preset="enter":
			-- Enter принимает текущий completion.
			vim.keymap.set("i", "<CR>", function()
				if vim.fn.pumvisible() == 0 then
					return "<CR>"
				end

				local selected = vim.fn.complete_info({ "selected" }).selected

				if selected == -1 then
					return "<C-e><CR>"
				end

				return "<C-y>"
			end, {
				expr = true,
				silent = true,
				noremap = true,
				desc = "Accept COQ completion",
			})

			-- Полная runtime-документация как fallback для Jedi.
			require("config.pydoc").setup()
		end,
	},
}
