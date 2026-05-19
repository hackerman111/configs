local opt = vim.opt

vim.g.mapleader = " "
vim.cmd("set termguicolors")
--vim.cmd("set clipboard+=unnamedplus")
vim.api.nvim_command("highlight BoldUnderline guisp=white guifg=white gui=bold,underline")

vim.g.vimtex_syntax_enabled = 0
vim.g.vimtex_complete_enabled = 0


-- Внешний вид
opt.number = true         -- Показывать номера строк
opt.relativenumber = true -- Показывать относительные номера строк
opt.termguicolors = true  -- Включить полноценные цвета в терминале
opt.signcolumn = "yes"    -- Всегда показывать колонку для знаков (ошибки, git)

-- Табуляция и отступы
opt.tabstop = 4       -- Ширина табуляции в пробелах
opt.shiftwidth = 4    -- Ширина отступа для автоотступа
opt.expandtab = true  -- Использовать пробелы вместо табов
opt.autoindent = true -- Включать автоотступ
vim.opt.undolevels = 5000
-- Поиск
opt.ignorecase = true -- Игнорировать регистр при поиске
opt.smartcase = true  -- Учитывать регистр, если в запросе есть заглавные буквы

-- Поведение редактора

opt.scrolloff = 8   -- Оставлять 8 строк контекста при скроллинге
opt.undofile = true -- Сохранять историю изменений между сессиями

-- Автоматический импорт/экспорт output-ов при работе с .ipynb
vim.api.nvim_create_autocmd("BufAdd", {
    pattern = "*.ipynb",
    callback = function(e)
        vim.schedule(function()
            local ok, kernel = pcall(function()
                local meta = vim.json.decode(io.open(e.file, "r"):read("*a")).metadata
                return meta.kernelspec.name
            end)
            if ok and kernel then
                vim.cmd("MoltenInit " .. kernel)
            end
            vim.cmd("MoltenImportOutput")
        end)
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.ipynb",
    callback = function()
        if require("molten.status").initialized() == "Molten" then
            vim.cmd("MoltenExportOutput!")
        end
    end,
})
