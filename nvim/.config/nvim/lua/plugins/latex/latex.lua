return {
    -- Поддержка LaTeX
    -- Поддержка LaTeX
    {
        "lervag/vimtex",
        init = function()
            -- Настройка просмотрщика и быстрого исправления ошибок
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_quickfix_mode = 0

            -- Настраиваем компилятор latexmk для работы с преамбулой
            vim.g.vimtex_compiler_latexmk = {
                -- Используем latexmk как основной инструмент для сборки
                executable = "latexmk",

                options = {
                    -- ВАЖНО: Преамбула уровня 290 требует LuaLaTeX или XeLaTeX.
                    -- Эта строка автоматически выберет lualatex, если он доступен, иначе xelatex.
                    "-lualatex",

                    -- Стандартные опции для удобной работы и отладки
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                    -- Разрешает LaTeX выполнять внешние команды. Необходимо для пакетов
                    -- вроде 'minted' (подсветка кода) или сложных импортов.
                    "-shell-escape",
                },
            }

            -- Удобные переключатели для окружений и разделителей
            vim.g.vimtex_env_toggle_map = { itemize = "enumerate", enumerate = "itemize" }
            vim.g.vimtex_delim_toggle_mod_list = { { "\\left", "\\right" }, { "\\big", "\\big" } }

            -- Горячая клавиша для компиляции
            vim.keymap.set("n", "<leader>LL", "<cmd>VimtexCompile<CR>", { desc = "Собрать LaTeX-документ" })
        end,
    },
    -- For `plugins/markview.lua` users.
}
