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

            local transparent = function()
                for _, group in ipairs({
                    "Normal",
                    "NormalNC",
                    "SignColumn",
                    "EndOfBuffer",
                    "LineNr",
                    "CursorLineNr",
                    "FoldColumn",
                    "NormalFloat",
                    "FloatBorder",
                    "Pmenu",
                }) do
                    vim.api.nvim_set_hl(0, group, { bg = "none" })
                end
            end

            transparent()

            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = transparent,
            })
        end,
    }
    ,
    ---Подсказки для команд
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = function()
            return require("config.move_and_navigation.which-key").opts
        end,
        config = function(_, opts)
            require("which-key").setup(opts)
            require("config.move_and_navigation.which-key").register()
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
                dashboard.button("o", "  Недавние файлы", ":Telescope oldfiles <CR>"),
                dashboard.button("p", "  Заметки", ":HarpoonTelescope <CR>"),
                dashboard.button("g", "  Найти по тексту", ":Telescope live_grep <CR>"),
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
            local colors = require("solarized-osaka.colors").setup()
            require("incline").setup({
                highlight = {
                    groups = {
                        InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
                        InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
                    },
                },
                window = { margin = { vertical = 0, horizontal = 1 } },
                hide = {
                    cursorline = true,
                },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    if vim.bo[props.buf].modified then
                        filename = "[+] " .. filename
                    end

                    local icon, color = require("nvim-web-devicons").get_icon_color(filename)
                    return { { icon, guifg = color }, { " " }, { filename } }
                end,
            })
        end,
    },
    ---Название буфера
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Следующая вкладка" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Предыдущая вкладка" },
        },
        opts = {
            options = {
                mode = "tabs",
                -- separator_style = "slant",
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },
}
