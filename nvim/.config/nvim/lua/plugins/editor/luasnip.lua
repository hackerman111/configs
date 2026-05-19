return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            local ls = require("luasnip")

            ls.config.set_config({
                enable_autosnippets = true,
                store_selection_keys = "<Tab>",
            })

            vim.cmd([[
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]])

            require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
            ls.filetype_extend("json", { "xray" })
            ls.filetype_extend("jsonc", { "xray" })
        end,
    },
}
