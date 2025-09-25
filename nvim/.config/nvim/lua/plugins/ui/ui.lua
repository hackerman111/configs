-- ~/.config/nvim/lua/plugins/ui.lua
-- Плагины, отвечающие за внешний вид

return {
	-- Статус-бар
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({ options = { theme = "auto", icons_enabled = true } })
		end,
	},
	-- Дерево файлов
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({})
		end,
	},
	-- Линии отступов
	-- Подсветка цветов
	{ "norcalli/nvim-colorizer.lua", opts = {} },
	-- Цветовая схема
	{
		"jacoborus/tender.vim",
	},
	-- Тема
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("nord")
		end,
	},
	---Подсказки для команд
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({})
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- more beautiful vim.ui.input
			input = {
				enabled = true,
				win = {
					relative = "cursor",
					backdrop = true,
				},
			},
			-- more beautiful vim.ui.select
			picker = { enabled = true },
		},
	},
	---Красивая заставка
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- Опционально, для иконок
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Устанавливаем ASCII-арт для заголовка
			dashboard.section.header.val = {
				[[ ┌─────────────────────────────────────────────────────────────────┐ ]],
				[[ │                     \`-._           __                          │ ]],
				[[ │                      \\  \-..____,.'  `.                        │ ]],
				[[ │                       :  )       :      :\                      │ ]],
				[[ │                        ;'        '   ;  | :                     │ ]],
				[[ │                        )..      .. .:.`.; :                     │ ]],
				[[ │                       /::...  .:::...   ` ;                     │ ]],
				[[ │                       `:o>   /\o_>        : `.                  │ ]],
				[[ │                      `-`.__ ;   __..--- /:.   \                 │ ]],
				[[ │                     ==== \_/   ;=====_.':.     ;                │ ]],
				[[ │                       ,/'`--'...`--....        ;                │ ]],
				[[ │                            ;                    ;               │ ]],
				[[ │                        . '                       ;              │ ]],
				[[ │                      .'     ..     ,      .       ;             │ ]],
				[[ │                     :       ::..  /      ;::.     |             │ ]],
				[[ │                    /      `.;::.  |       ;:..    ;             │ ]],
				[[ │                   :         |:.   :       ;:.    ;              │ ]],
				[[ │                   :         ::     ;:..   |.    ;               │ ]],
				[[ │                    :       :;      :::....|     |               │ ]],
				[[ │                    /\     ,/ \      ;:::::;     ;               │ ]],
				[[ │                  .:. \:..|    :     ; '.--|     ;               │ ]],
				[[ │                 ::.  :''  `-.,,;     ;'   ;     ;               │ ]],
				[[ │              .-'. _.'\      / `;      \,__:      \              │ ]],
				[[ │              `---'    `----'   ;      /    \,.,,,/              │ ]],
				[[ │                                 `----`                          │ ]],
				[[ └─────────────────────────────────────────────────────────────────┘ ]],
				[[         ███╗   ███ ███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗         ]],
				[[         ████╗ ████║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║         ]],
				[[         ██╔████╔██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║         ]],
				[[         ██║╚██╔╝██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║         ]],
				[[         ██║ ╚═╝ ██║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║         ]],
				[[         ╚═╝     ╚═╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝         ]],
			}

			-- Получаем путь к папке с конфигурацией
			local config_path = vim.fn.stdpath("config")
			-- Эта функция будет отвечать за логику переключения
			local function toggle_telescope_harpoon()
				-- Получаем текущий открытый пикер Telescope
				local picker = require("telescope.actions.state").get_current_picker()

				-- Если пикер Telescope уже открыт, мы его закрываем
				if picker then
					require("telescope.actions").close()
					return
				end

				-- Если пикер не открыт, мы создаем новый со списком из Harpoon
				-- и показываем его
				require("move_and_navigation.telescope").extensions.harpoon.marks()
			end

			-- Создаем пользовательскую команду :ToggleHarpoon
			vim.api.nvim_create_user_command(
				"ToggleHarpoon",
				toggle_telescope_harpoon,
				{ desc = "Переключить Telescope для списка Harpoon" }
			)

			-- Настраиваем кнопки-меню
			dashboard.section.buttons.val = {
				-- Новая кнопка для файлов проекта
				dashboard.button("o", "  Недавние файлы", ":Telescope oldfiles <CR>"),
				dashboard.button("p", "  Заметки", ":ToggleHarpoon <CR>"),
				-- Другие полезные кнопки
				dashboard.button("g", "  Найти по тексту", ":Telescope live_grep <CR>"),
				-- Новая кнопка для файлов конфигурации
				dashboard.button(
					"c",
					"  Файлы конфига",
					":Telescope find_files cwd=" .. config_path .. " <CR>"
				),
				dashboard.button("q", "  Выход", ":qa <CR>"),
			}

			-- Применяем тему dashboard
			alpha.setup(dashboard.opts)
		end,
	},
	---Название файла
	{
		"b0o/incline.nvim",
		dependencies = { "craftzdog/solarized-osaka.nvim" },
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local colors = require("solarized-osaka.colors").setup()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
						InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },
				hide = {
					cursorline = true,
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end

					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},
	---Название буфера
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
}
