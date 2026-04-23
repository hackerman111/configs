-- ~/.config/nvim/lua/plugins/ui.lua
-- Плагины, отвечающие за внешний вид

return {
	-- Статус-бар
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup(require("config.ui").lualine_opts())
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
		opts = function()
			return require("config.move_and_navigation.which-key").opts
		end,
		config = function(_, opts)
			require("which-key").setup(opts)
			require("config.move_and_navigation.which-key").register()
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = function()
			return require("config.ui").snacks_opts()
		end,
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

				local config_path = vim.fn.stdpath("config")

				dashboard.section.buttons.val = {
					dashboard.button("o", "  Недавние файлы", ":Telescope oldfiles <CR>"),
					dashboard.button("p", "  Заметки", ":HarpoonTelescope <CR>"),
					dashboard.button("g", "  Найти по тексту", ":Telescope live_grep <CR>"),
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
		event = "BufReadPre",
		priority = 1200,
		config = function()
			require("incline").setup(require("config.ui").incline_opts())
		end,
	},
	---Название буфера
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Следующая вкладка" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Предыдущая вкладка" },
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
