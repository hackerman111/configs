return {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = {
        "nmac427/guess-indent.nvim",
    },
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },

    config = function()
        require("guess-indent").setup({})

        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }

        local hooks = require("ibl.hooks")

        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

            -- Главное исправление ошибки:
            vim.api.nvim_set_hl(0, "IblScope", {
                fg = "#81A1C1",
                nocombine = true,
            })
        end)

        require("ibl").setup({
            indent = {
                char = "│",
                highlight = highlight,
            },

            scope = {
                enabled = true,
                char = "│",
                highlight = "IblScope",
                show_start = false,
                show_end = false,
            },

            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "NvimTree",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "Trouble",
                },
            },
        })
    end,
}
