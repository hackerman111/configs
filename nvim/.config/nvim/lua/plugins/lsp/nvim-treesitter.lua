-- ~/.config/nvim/lua/plugins/lsp/nvim-treesitter.lua
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- обязательно в 2026
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,

    opts = {
        ensure_installed = {
            "python", "markdown", "markdown_inline", "latex", "bibtex",
            "lua", "vim", "vimdoc", "query", "html", "css", "javascript",
            "json", "yaml", "toml", "bash", "regex", "c", "cpp"
        },
        auto_install = true,
        sync_install = false,
        ignore_install = {},

        highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" }, -- критично для ipynb + render-markdown
            disable = {},                                 -- если latex будет конфликтовать — добавь "latex"
        },

        indent = { enable = true },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<C-space>",
                node_incremental = "<C-space>",
                scope_incremental = false,
                node_decremental = "<bs>",
            },
        },
    },

    config = function(_, opts)
        require("nvim-treesitter.config").setup(opts) -- ← НОВОЕ ИМЯ МОДУЛЯ (2026)
        vim.g.nvim_treesitter_legacy_modules = opts

        local parsers = require("nvim-treesitter.parsers")
        if parsers.ft_to_lang == nil and vim.treesitter.language and vim.treesitter.language.get_lang then
            parsers.ft_to_lang = function(filetype)
                return vim.treesitter.language.get_lang(filetype) or filetype
            end
        end
        if parsers.get_parser == nil and vim.treesitter.get_parser then
            parsers.get_parser = function(bufnr, lang)
                return vim.treesitter.get_parser(bufnr, lang)
            end
        end
    end,
}
