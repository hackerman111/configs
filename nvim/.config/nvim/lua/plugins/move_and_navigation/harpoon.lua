return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")

		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local telescope_config = require("telescope.config").values

		harpoon:setup()

		---Собирает актуальные элементы Harpoon.
		local function get_harpoon_entries()
			local list = harpoon:list()
			local entries = {}

			for index = 1, list:length() do
				local item = list:get(index)

				if item and item.value then
					entries[#entries + 1] = {
						index = index,
						item = item,
						path = item.value,
					}
				end
			end

			return entries
		end

		---Создаёт finder из текущего состояния Harpoon.
		local function make_harpoon_finder()
			return finders.new_table({
				results = get_harpoon_entries(),

				entry_maker = function(entry)
					return {
						value = entry,

						display = string.format("%2d  %s", entry.index, vim.fn.fnamemodify(entry.path, ":~:.")),

						ordinal = entry.path,
						filename = entry.path,
					}
				end,
			})
		end

		local function open_harpoon_picker()
			pickers
				.new({
					initial_mode = "normal",
				}, {
					prompt_title = "Harpoon",

					finder = make_harpoon_finder(),
					previewer = telescope_config.file_previewer({}),
					sorter = telescope_config.generic_sorter({}),

					attach_mappings = function(prompt_bufnr, map)
						local function delete_selected()
							local selection = action_state.get_selected_entry()

							if not selection or not selection.value then
								return
							end

							local entry = selection.value
							local list = harpoon:list()

							-- Удаляем именно выбранную позицию Harpoon.
							list:remove_at(entry.index)

							-- Пересобираем finder, поэтому строка сразу исчезает.
							local picker = action_state.get_current_picker(prompt_bufnr)

							picker:refresh(make_harpoon_finder(), {
								reset_prompt = false,
							})
						end

						-- Normal mode.
						map("n", "d", delete_selected)

						-- На случай ручного перехода в insert mode.
						map("i", "<C-d>", delete_selected)

						map("n", "q", actions.close)

						return true
					end,
				})
				:find()
		end

		vim.api.nvim_create_user_command("HarpoonMenu", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, {
			desc = "Открыть быстрое меню Harpoon",
		})

		vim.api.nvim_create_user_command("HarpoonTelescope", open_harpoon_picker, {
			desc = "Открыть список Harpoon в Telescope",
		})

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, {
			desc = "Harpoon: добавить текущий файл",
		})

		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, {
			desc = "Harpoon: открыть быстрое меню",
		})

		vim.keymap.set("n", "<leader>hn", function()
			harpoon:list():next()
		end, {
			desc = "Harpoon: перейти к следующему файлу",
		})

		vim.keymap.set("n", "<leader>hp", function()
			harpoon:list():prev()
		end, {
			desc = "Harpoon: перейти к предыдущему файлу",
		})

		vim.keymap.set("n", "<leader>hr", function()
			harpoon:list():remove()
		end, {
			desc = "Harpoon: удалить текущий файл",
		})

		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
		end, {
			desc = "Harpoon: очистить список",
		})

		vim.keymap.set("n", "<leader>hh", open_harpoon_picker, {
			desc = "Harpoon: открыть Telescope",
		})
	end,
}
