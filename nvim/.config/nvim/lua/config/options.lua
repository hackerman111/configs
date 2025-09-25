local opt = vim.opt

vim.g.mapleader = " "
vim.cmd("set termguicolors")
vim.api.nvim_command("highlight BoldUnderline guisp=white guifg=white gui=bold,underline")

-- Внешний вид
opt.number = true -- Показывать номера строк
opt.relativenumber = true -- Показывать относительные номера строк
opt.termguicolors = true -- Включить полноценные цвета в терминале
opt.signcolumn = "yes" -- Всегда показывать колонку для знаков (ошибки, git)

-- Табуляция и отступы
opt.tabstop = 4 -- Ширина табуляции в пробелах
opt.shiftwidth = 4 -- Ширина отступа для автоотступа
opt.expandtab = true -- Использовать пробелы вместо табов
opt.autoindent = true -- Включать автоотступ

-- Поиск
opt.ignorecase = true -- Игнорировать регистр при поиске
opt.smartcase = true -- Учитывать регистр, если в запросе есть заглавные буквы

-- Поведение редактора

opt.scrolloff = 8 -- Оставлять 8 строк контекста при скроллинге
opt.undofile = true -- Сохранять историю изменений между сессиями
