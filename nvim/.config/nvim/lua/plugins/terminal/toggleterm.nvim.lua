return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			function _G.set_terminal_keymaps()
				local opts = { noremap = true }
				vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
			end

			vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

			require("toggleterm").setup({
				-- size can be a number or function which is passed the current terminal
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<F12>]],
				---@diagnostic disable-next-line: unused-local
				on_open = function(term) end,
				---@diagnostic disable-next-line: unused-local
				on_close = function(term) end,
				highlights = {
					-- highlights which map to a highlight group name and a table of it's values
					-- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
					Normal = {
						link = "Normal",
					},
					NormalFloat = {
						link = "Normal",
					},
					FloatBorder = {
						-- guifg = <VALUE-HERE>,
						-- guibg = <VALUE-HERE>,
						link = "FloatBorder",
					},
				},
				shade_filetypes = {},
				shade_terminals = false,
				shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
				start_in_insert = true,
				insert_mappings = true, -- whether or not the open mapping applies in insert mode
				persist_size = true,
				direction = "horizontal", -- | 'horizontal' | 'window' | 'float',
				close_on_exit = true, -- close the terminal window when the process exits
				shell = vim.o.shell, -- change the default shell
				-- This field is only relevant if direction is set to 'float'
				float_opts = {
					-- The border key is *almost* the same as 'nvim_win_open'
					-- see :h nvim_win_open for details on borders however
					-- the 'curved' border is a custom border type
					-- not natively supported but implemented in this plugin.
					border = "curved", -- single/double/shadow/curved
					width = math.floor(0.7 * vim.fn.winwidth(0)),
					height = math.floor(0.8 * vim.fn.winheight(0)),
					winblend = 0,
				},
				winbar = {
					enabled = true,
				},
			})

			local Terminal = require("toggleterm.terminal").Terminal

			local runner_terminal = Terminal:new({
				direction = "float",
				hidden = true,
				close_on_exit = false,
				display_name = "Run current file",
			})

			local function get_run_command()
				local file = vim.api.nvim_buf_get_name(0)

				if file == "" then
					vim.notify("Буфер не связан с файлом", vim.log.levels.WARN)
					return nil
				end

				local escaped_file = vim.fn.shellescape(file)
				local filetype = vim.bo.filetype

				local commands = {
					python = "python3 " .. escaped_file,
					lua = "lua " .. escaped_file,
					javascript = "node " .. escaped_file,
					typescript = "npx tsx " .. escaped_file,
					sh = "bash " .. escaped_file,
					zsh = "zsh " .. escaped_file,
					ruby = "ruby " .. escaped_file,
					go = "go run " .. escaped_file,

					c = "cc " .. escaped_file .. " -o /tmp/nvim-run && /tmp/nvim-run",

					cpp = "c++ " .. escaped_file .. " -o /tmp/nvim-run && /tmp/nvim-run",
				}

				local command = commands[filetype]

				if not command then
					vim.notify(
						"Нет команды запуска для filetype: " .. filetype,
						vim.log.levels.WARN
					)
					return nil
				end

				return command
			end

			local function send_command_when_ready(command, attempt)
				attempt = attempt or 1

				if not runner_terminal.job_id then
					if attempt >= 40 then
						vim.notify("Не удалось запустить shell в ToggleTerm", vim.log.levels.ERROR)
						return
					end

					vim.defer_fn(function()
						send_command_when_ready(command, attempt + 1)
					end, 25)

					return
				end

				-- Даём zsh время вывести первый prompt.
				vim.defer_fn(function()
					if not runner_terminal.job_id then
						return
					end

					-- Ctrl-U очищает текущую строку.
					-- Ctrl-L очищает видимую область терминала.
					local clear_line_and_screen = string.char(21, 12)

					vim.api.nvim_chan_send(runner_terminal.job_id, clear_line_and_screen .. command)

					if runner_terminal:is_open() then
						vim.cmd.startinsert()
					end
				end, 200)
			end

			local function open_runner_with_command()
				-- Получаем путь до переключения на terminal-buffer.
				local command = get_run_command()

				if not command then
					return
				end

				-- open() нельзя вызывать прямо во время первой lazy-загрузки
				-- по хоткею: переносим его за пределы текущего обработчика.
				vim.schedule(function()
					runner_terminal:open()
					send_command_when_ready(command)
				end)
			end

			vim.keymap.set("n", "<Leader>aT", open_runner_with_command, {
				desc = "Терминал с запуском текущего файла",
				silent = true,
			})
		end,
		keys = {
			{ "<F5>", desc = "Открыть/закрыть терминал" },
			{ "<Leader>at", "<cmd>ToggleTerm direction=float<CR>", desc = "Плавающий терминал" },
			{
				"<Leader>aT",
				desc = "Терминал с запуском текущего файла",
			},
		},
	},
}
