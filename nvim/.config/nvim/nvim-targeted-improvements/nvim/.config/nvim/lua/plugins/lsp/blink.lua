return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"L3MON4D3/LuaSnip",
		},
		opts = {
			enabled = function()
				local ft = vim.bo.filetype
				if vim.tbl_contains({ "TelescopePrompt", "minifiles", "snacks_picker_input", "tex", "dap-repl" }, ft) then
					return false
				end
				return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
			end,

			snippets = { preset = "luasnip" },

			-- Do not let completion steal Enter or Tab. Enter stays newline;
			-- Tab/S-Tab stay owned by LuaSnip from plugins/editor/luasnip.lua.
			keymap = {
				preset = "none",
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-n>"] = { "select_next", "fallback_to_mappings" },
				["<C-p>"] = { "select_prev", "fallback_to_mappings" },
				["<C-y>"] = { "select_and_accept", "fallback" },
				["<C-e>"] = { "cancel", "fallback" },
			},

			completion = {
				keyword = { range = "prefix" },
				list = {
					max_items = 40,
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
				menu = {
					border = "single",
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
					},
				},
				documentation = {
					auto_show = false,
					window = { border = "single" },
				},
				ghost_text = { enabled = false },
			},

			-- Keep completion semantic and small. Buffer/dictionary/ripgrep sources
			-- create many plausible but low-value candidates while coding.
			sources = {
				default = { "lsp", "path", "snippets" },
				providers = {
					lsp = {
						min_keyword_length = 1,
						max_items = 28,
					},
					path = {
						-- Blink's own default is a small +3 preference. The previous
						-- +100 effectively overrode fuzzy score/frecency.
						score_offset = 3,
						max_items = 10,
					},
					snippets = {
						max_items = 8,
					},
				},
			},

			fuzzy = {
				implementation = "prefer_rust",
				max_typos = function(keyword)
					return #keyword >= 6 and 1 or 0
				end,
				sorts = { "exact", "score", "sort_text" },
			},

			-- lsp_signature.nvim already owns signature UI in this config.
			signature = { enabled = false },

			cmdline = {
				keymap = { preset = "cmdline" },
				completion = {
					menu = { auto_show = false },
					list = {
						selection = {
							preselect = false,
							auto_insert = false,
						},
					},
				},
			},
		},
	},
}
