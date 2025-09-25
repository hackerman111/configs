-- ~/.config/nvim/lua/core/keymaps.lua
-- Централизованный файл для всех сочетаний клавиш.
-- Для удобства рекомендуется вызывать этот файл из вашего init.lua: require('core.keymaps')

local map = vim.keymap.set

-- =============================================================================
--  ОСНОВНЫЕ И НАВИГАЦИЯ
-- =============================================================================

-- Улучшенное перемещение
map("n", "<esc>", "<cmd>nohlsearch<CR>", { desc = "Сброс подсветки поиска" })
map("n", "yy", '"+Y', { desc = "Копировать в системный буфер обмена" })
-- Навигация по окнам
map("n", "<A-h>", "<C-w>v", { desc = "Разделить окно вертикально" })
map("n", "<A-k>", "<C-w>s", { desc = "Разделить окно горизонтально" })

-- Отключить стандартные стрелки, чтобы привыкнуть к h,j,k,l
map("n", "<Left>", '<cmd>echo "Используйте h для навигации влево"<CR>', { silent = true })
map(
	"n",
	"<Right>",
	'<cmd>echo "Используйте l для навигации вправо"<CR>',
	{ silent = true }
)
map("n", "<Up>", '<cmd>echo "Используйте k для навигации вверх"<CR>', { silent = true })
map("n", "<Down>", '<cmd>echo "Используйте j для навигации вниз"<CR>', { silent = true })

-- =============================================================================
--  ПЛАГИНЫ
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Поиск (Telescope, Spectre, SSR)
-- -----------------------------------------------------------------------------

-- Spectre (Поиск и замена по проекту)
map(
	"n",
	"<leader>S",
	'<cmd>lua require("spectre").toggle()<CR>',
	{ desc = "Поиск и замена по проекту (Spectre)" }
)
map(
	"n",
	"<leader>sw",
	'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
	{ desc = "Найти текущее слово (Spectre)" }
)
map(
	"v",
	"<leader>sw",
	'<esc><cmd>lua require("spectre").open_visual()<CR>',
	{ desc = "Найти выделенное (Spectre)" }
)
map(
	"n",
	"<leader>sp",
	'<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
	{ desc = "Поиск и замена в файле (Spectre)" }
)

-- SSR (Структурный поиск и замена)
map({ "n", "x" }, "<leader>sr", function()
	require("ssr").open()
end, { desc = "Структурный поиск и замена (SSR)" })

-- -----------------------------------------------------------------------------
-- Быстрая навигация (Harpoon, Leap/Flash, Oil)
-- -----------------------------------------------------------------------------

-- Harpoon (Закладки для файлов)
map("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, { desc = "Harpoon: добавить файл в список" })
map("n", "<C-e>", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Harpoon: показать меню быстрого доступа" })
map("n", "<leader>hn", function()
	require("harpoon"):list():prev()
end, { desc = "Harpoon: перейти к предыдущему файлу" })
map("n", "<leader>hp", function()
	require("harpoon"):list():next()
end, { desc = "Harpoon: перейти к следующему файлу" })
map("n", "<leader>hr", function()
	require("harpoon"):list():remove()
end, { desc = "Harpoon: удалить файл из списка" })
map("n", "<leader>hc", function()
	require("harpoon"):list():clear()
end, { desc = "Harpoon: очистить список" })

-- Leap & Flash (Прыжки по коду)
map("n", "s", "<Plug>(leap-anywhere)", { desc = "Leap: прыжок в любое место" })
map("o", "s", "<Plug>(leap)", { desc = "Leap: прыжок вперед (оператор)" })
map("n", "S", "<Plug>(leap-from-window)", { desc = "Leap: прыжок из окна" })
map("x", "s", function()
	require("flash").treesitter()
end, { desc = "Flash: перейти к объекту Tree-sitter" })
map({ "x", "o" }, "S", function()
	require("flash").treesitter_search()
end, { desc = "Flash: найти Tree-sitter объект" })
map("o", "r", function()
	require("flash").remote()
end, { desc = "Flash: удаленный оператор" })
map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Flash: поиск по объектам Tree-sitter" })

-- Jumplist (Пользовательский список переходов)
map("n", "<leader>ji", function()
	require("jumplist"):add_to_jump_list()
end, { desc = "Добавить в jumplist" })
map("n", "<leader>jj", function()
	require("jumplist"):picker()
end, { desc = "Показать jumplist" })

-- Oil (Файловый менеджер)
map("n", "-", "<CMD>Oil<CR>", { desc = "Открыть родительскую директорию (Oil)" })

-- -----------------------------------------------------------------------------
-- Редактирование (Yanky, Conform, Multicursors, Text-case)
-- -----------------------------------------------------------------------------

-- Conform (Форматирование)
map({ "n", "v" }, "<leader>gf", function()
	require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 500 })
end, { desc = "Форматировать файл или выделение" })

-- Multicursors (Множественные курсоры)
map({ "v", "n" }, "<Leader>m", "<cmd>MCstart<cr>", { desc = "Создать множественный курсор" })

-- text-case.nvim (Изменение регистра текста)
map(
	{ "n", "x" },
	"ga.",
	"<cmd>TextCaseOpenTelescope<CR>",
	{ desc = "Изменить регистр текста (Telescope)" }
)

-- -----------------------------------------------------------------------------
-- Работа с LaTeX (Vimtex & Inkscape)
-- -----------------------------------------------------------------------------

-- Vimtex
map(
	"n",
	"dsm",
	"<Plug>(vimtex-env-delete-math)",
	{ noremap = true, desc = "Vimtex: удалить math окружение" }
)
map(
	"n",
	"tsf",
	"<Plug>(vimtex-env-toggle-math)",
	{ noremap = true, desc = "Vimtex: переключить math окружение" }
)
map(
	{ "o", "x" },
	"ai",
	"<Plug>(vimtex-am)",
	{ noremap = true, desc = "Vimtex: текстовый объект 'a math'" }
)
map(
	{ "o", "x" },
	"ii",
	"<Plug>(vimtex-im)",
	{ noremap = true, desc = "Vimtex: текстовый объект 'inner math'" }
)
map(
	{ "o", "x" },
	"am",
	"<Plug>(vimtex-a$)",
	{ noremap = true, desc = "Vimtex: текстовый объект 'a inline math'" }
)
map(
	{ "o", "x" },
	"im",
	"<Plug>(vimtex-i$)",
	{ noremap = true, desc = "Vimtex: текстовый объект 'inner inline math'" }
)
map(
	{ "n", "x", "o" },
	"%",
	"<Plug>(vimtex-%)",
	{ noremap = true, desc = "Vimtex: перейти к парной скобке" }
)

-- Inkscape (требует установленного inkscape-figures)
map(
	"i",
	"<C-f>",
	"<Esc>: silent exec '.!inkscape-figures create \"'.getline('.').'\" \"'.b:vimtex.root.'/figures/\"'<CR><CR>:w<CR>",
	{ desc = "Создать Inkscape фигуру" }
)
map(
	"n",
	"<C-f>",
	": silent exec '!inkscape-figures edit \"'.b:vimtex.root.'/figures/\" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>",
	{ desc = "Редактировать Inkscape фигуры" }
)
