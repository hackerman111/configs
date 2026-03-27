return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		local telescope_config = require("telescope.config").values

		harpoon:setup()

		local function open_harpoon_picker()
			local file_paths = {}

			for _, item in ipairs(harpoon:list().items) do
				if item.value then
					table.insert(file_paths, item.value)
				end
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = telescope_config.file_previewer({}),
					sorter = telescope_config.generic_sorter({}),
				})
				:find()
		end

		vim.api.nvim_create_user_command("HarpoonMenu", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Открыть быстрое меню Harpoon" })

		vim.api.nvim_create_user_command("HarpoonTelescope", open_harpoon_picker, {
			desc = "Открыть список Harpoon в Telescope",
		})

		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Harpoon: добавить текущий файл" })
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: открыть быстрое меню" })
		vim.keymap.set("n", "<leader>hn", function()
			harpoon:list():next()
		end, { desc = "Harpoon: перейти к следующему файлу" })
		vim.keymap.set("n", "<leader>hp", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: перейти к предыдущему файлу" })
		vim.keymap.set("n", "<leader>hr", function()
			harpoon:list():remove()
		end, { desc = "Harpoon: удалить текущий файл" })
		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
		end, { desc = "Harpoon: очистить список" })
		vim.keymap.set("n", "<leader>fh", open_harpoon_picker, {
			desc = "Открыть список Harpoon через Telescope",
		})
	end,
}
