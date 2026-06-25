local map = vim.keymap.set

map("n", "<esc>", "<cmd>nohlsearch<CR>", { desc = "Сбросить подсветку поиска" })
map("n", "yy", '"+Y', { desc = "Скопировать строку в системный буфер" })

map("n", "<Left>", '<cmd>echo "Используйте h для движения влево"<CR>', { silent = true, desc = "Подсказка: h" })
map("n", "<Right>", '<cmd>echo "Используйте l для движения вправо"<CR>', { silent = true, desc = "Подсказка: l" })
map("n", "<Up>", '<cmd>echo "Используйте k для движения вверх"<CR>', { silent = true, desc = "Подсказка: k" })
map("n", "<Down>", '<cmd>echo "Используйте j для движения вниз"<CR>', { silent = true, desc = "Подсказка: j" })

map("n", "<leader>wh", "<C-w>h", { desc = "Окно слева" })
map("n", "<leader>wj", "<C-w>j", { desc = "Окно снизу" })
map("n", "<leader>wk", "<C-w>k", { desc = "Окно сверху" })
map("n", "<leader>wl", "<C-w>l", { desc = "Окно справа" })
map("n", "<leader>ww", "<C-w>w", { desc = "Следующее окно" })
map("n", "<leader>wp", "<C-w>p", { desc = "Предыдущее окно" })
map("n", "<leader>wv", "<C-w>v", { desc = "Разделить окно вертикально" })
map("n", "<leader>ws", "<C-w>s", { desc = "Разделить окно горизонтально" })
map("n", "<leader>wc", "<C-w>c", { desc = "Закрыть текущее окно" })
map("n", "<leader>wo", "<C-w>o", { desc = "Оставить только текущее окно" })
map("n", "<leader>w=", "<C-w>=", { desc = "Выровнять размеры окон" })

map({ "v", "n" }, "<leader>m", "<cmd>MCstart<cr>", { desc = "Запустить множественные курсоры" })

map("n", "dsm", "<Plug>(vimtex-env-delete-math)", { noremap = true, desc = "Vimtex: удалить math-окружение" })
map("n", "tsf", "<Plug>(vimtex-env-toggle-math)", { noremap = true, desc = "Vimtex: переключить math-окружение" })
map({ "o", "x" }, "ai", "<Plug>(vimtex-am)", { noremap = true, desc = "Vimtex: объект a math" })
map({ "o", "x" }, "ii", "<Plug>(vimtex-im)", { noremap = true, desc = "Vimtex: объект inner math" })
map({ "o", "x" }, "am", "<Plug>(vimtex-a$)", { noremap = true, desc = "Vimtex: объект a inline math" })
map({ "o", "x" }, "im", "<Plug>(vimtex-i$)", { noremap = true, desc = "Vimtex: объект inner inline math" })
map({ "n", "x", "o" }, "%", "<Plug>(vimtex-%)", { noremap = true, desc = "Vimtex: перейти к парной скобке" })

map(
    "i",
    "<C-f>",
    "<Esc>: silent exec '.!inkscape-figures create \"'.getline('.').'\" \"'.b:vimtex.root.'/figures/\"'<CR><CR>:w<CR>",
    { desc = "Создать фигуру через Inkscape" }
)
map(
    "n",
    "<C-f>",
    ": silent exec '!inkscape-figures edit \"'.b:vimtex.root.'/figures/\" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>",
    { desc = "Открыть фигуры Inkscape" }
)
vim.api.nvim_create_user_command("Zathura", function(opts)
    local file = vim.fn.expand(opts.args)

    if file == "" then
        print("Укажи файл: :Zathura path/to/file.pdf")
        return
    end

    if vim.fn.filereadable(file) == 0 then
        print("Файл не найден: " .. file)
        return
    end

    vim.fn.jobstart({ "zathura", file }, { detach = true })
end, {
    nargs = 1,
    complete = "file",
})
