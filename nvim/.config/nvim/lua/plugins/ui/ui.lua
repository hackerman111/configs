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
			return require("config.which-key").opts
		end,
		config = function(_, opts)
			require("which-key").setup(opts)
			require("config.which-key").register()
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

			local config_path = vim.fn.stdpath("config")

			dashboard.section.buttons.val = {
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
			local devicons = require("nvim-web-devicons")
			require("incline").setup({
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if filename == "" then
						filename = "[No Name]"
					end
					local ft_icon, ft_color = devicons.get_icon_color(filename)

					local function get_git_diff()
						local icons = { removed = "", changed = "", added = "" }
						local signs = vim.b[props.buf].gitsigns_status_dict
						local labels = {}
						if signs == nil then
							return labels
						end
						for name, icon in pairs(icons) do
							if tonumber(signs[name]) and signs[name] > 0 then
								table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
							end
						end
						if #labels > 0 then
							table.insert(labels, { "┊ " })
						end
						return labels
					end

					local function get_diagnostic_label()
						local icons = { error = "", warn = "", info = "", hint = "" }
						local label = {}

						for severity, icon in pairs(icons) do
							local n = #vim.diagnostic.get(
								props.buf,
								{ severity = vim.diagnostic.severity[string.upper(severity)] }
							)
							if n > 0 then
								table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
							end
						end
						if #label > 0 then
							table.insert(label, { "┊ " })
						end
						return label
					end

					return {
						{ get_diagnostic_label() },
						{ get_git_diff() },
						{ (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
						{
							filename .. " ",
							vim.bo[props.buf].modified and "●" or "✓",
							gui = vim.bo[props.buf].modified and "bold,italic" or "bold",
						},
					}
				end,
			})
		end,
	},
	---Название буфера
	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Следующая вкладка" },
	-- 		{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Предыдущая вкладка" },
	-- 	},
	-- 	opts = {
	-- 		options = {
	-- 			mode = "tabs",
	-- 			-- separator_style = "slant",
	-- 			show_buffer_close_icons = false,
	-- 			show_close_icon = false,
	-- 		},
	-- 	},
	-- },
}
