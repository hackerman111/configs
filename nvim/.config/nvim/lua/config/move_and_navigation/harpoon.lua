local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon: добавить текущий файл" })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: открыть меню" })


-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hn", function() harpoon:list():prev() end, { desc = "Harpoon: перейти к предыдущему файлу" })
vim.keymap.set("n", "<leader>hp", function() harpoon:list():next() end, { desc = "Harpoon: перейти к следующему файлу" })
vim.keymap.set("n", "<leader>hr", function()
  require("harpoon"):list():remove()
end, { desc = "Harpoon: удалить текущий файл" })
vim.keymap.set("n", "<leader>hc", function()
  require("harpoon"):list():clear()
end, { desc = "Harpoon: очистить список" })

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>fh", function() toggle_telescope(harpoon:list()) end,
    { desc = "Открыть загарпуненные файлы" })
