local completion = require("config.completion")

local function border_style()
	if vim.o.pumborder ~= "" then
		return vim.o.pumborder
	end
	if vim.o.winborder ~= "" then
		return vim.o.winborder
	end
	return "rounded"
end

local function dictionary_dir()
	return vim.fn.stdpath("config") .. "/dict"
end

local function setup_blink_highlights()
	local highlights = {
		BlinkCmpMenu = { fg = "#d8dee9", bg = "#2b303b" },
		BlinkCmpMenuBorder = { fg = "#4c566a", bg = "#2b303b" },
		BlinkCmpMenuSelection = { fg = "#eceff4", bg = "#3b4252", bold = true },
		BlinkCmpLabel = { fg = "#e5e9f0", bg = "#2b303b" },
		BlinkCmpLabelDescription = { fg = "#81a1c1", bg = "#2b303b", italic = true },
		BlinkCmpSource = { fg = "#88c0d0", bg = "#2b303b" },
		BlinkCmpGhostText = { fg = "#616e88", italic = true },
		BlinkCmpDoc = { fg = "#d8dee9", bg = "#2e3440" },
		BlinkCmpDocBorder = { fg = "#4c566a", bg = "#2e3440" },
		BlinkCmpSignatureHelp = { fg = "#d8dee9", bg = "#2e3440" },
		BlinkCmpSignatureHelpBorder = { fg = "#4c566a", bg = "#2e3440" },
		BlinkCmpItemIdx = { fg = "#5e81ac", bg = "#2b303b", bold = true },
	}

	for group, value in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, value)
	end
end

local function setup_blink_autocmds()
	local group = vim.api.nvim_create_augroup("BlinkCmpPolish", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = setup_blink_highlights,
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "BlinkCmpMenuOpen",
		callback = function()
			local ok, suggestion = pcall(require, "copilot.suggestion")
			if ok and type(suggestion.dismiss) == "function" then
				suggestion.dismiss()
			end
			vim.b.copilot_suggestion_hidden = true
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "BlinkCmpMenuClose",
		callback = function()
			vim.b.copilot_suggestion_hidden = false
		end,
	})

	setup_blink_highlights()
end

local function blink_enabled()
	if not completion.is_blink() then
		return false
	end

	local filetype = vim.bo[0].filetype
	return not vim.tbl_contains({
		"TelescopePrompt",
		"minifiles",
		"snacks_picker_input",
	}, filetype)
end

local function path_kind_icon(ctx)
	local icon = ctx.kind_icon
	if vim.tbl_contains({ "Path" }, ctx.source_name) then
		local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
		if dev_icon then
			icon = dev_icon
		end
	else
		icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
	end
	return " " .. icon .. ctx.icon_gap
end

local function path_kind_highlight(ctx)
	if vim.tbl_contains({ "Path" }, ctx.source_name) then
		local _, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
		if dev_hl then
			return dev_hl
		end
	end
	return ctx.kind_hl
end

return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = function()
			local coq_mode = completion.is_coq()

			return {
				suggestion = {
					enabled = coq_mode,
					auto_trigger = false,
					hide_during_completion = true,
					keymap = {
						accept = false,
						accept_word = false,
						accept_line = false,
						next = false,
						prev = false,
						dismiss = false,
					},
				},
				panel = { enabled = false },
				filetypes = {
					markdown = false,
					tex = false,
					help = true,
				},
			}
		end,
	},
	{
		"saghen/blink.cmp",
		version = "*",
		enabled = blink_enabled,
		dependencies = {
			"onsails/lspkind.nvim",
			"moyiz/blink-emoji.nvim",
			"Kaiser-Yang/blink-cmp-dictionary",
			"fang2hou/blink-copilot",
			"mikavilpas/blink-ripgrep.nvim",
		},
		init = setup_blink_autocmds,
		opts = function(_, opts)
			opts.enabled = blink_enabled
			opts.snippets = nil

			opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
				preset = "enter",
				["<C-y>"] = { "select_and_accept", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
			})

			opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
				default = {
					"lsp",
					"path",
					"buffer",
					"copilot",
					"emoji",
					"dictionary",
					"ripgrep",
				},
				per_filetype = {
					lua = { inherit_defaults = true, "lsp", "path", "buffer", "copilot", "ripgrep" },
					markdown = { "buffer", "path", "dictionary", "emoji", "ripgrep", "copilot" },
					text = { "buffer", "dictionary", "emoji", "ripgrep" },
					gitcommit = { "buffer", "dictionary", "emoji", "ripgrep" },
					tex = { "buffer", "path", "dictionary", "ripgrep" },
				},
				providers = {
					copilot = {
						name = "AI",
						module = "blink-copilot",
						min_keyword_length = 3,
						score_offset = 120,
						max_items = 4,
						async = true,
					},
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						min_keyword_length = 0,
						score_offset = 100,
						fallbacks = {},
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = 110,
						min_keyword_length = 0,
						fallbacks = { "buffer" },
						opts = {
							trailing_slash = false,
							label_trailing_slash = true,
							get_cwd = function(context)
								return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
							end,
							show_hidden_files_by_default = true,
						},
					},
					buffer = {
						name = "Buf",
						module = "blink.cmp.sources.buffer",
						min_keyword_length = 3,
						max_items = 5,
						score_offset = 20,
					},
					emoji = {
						name = "Emoji",
						module = "blink-emoji",
						min_keyword_length = 2,
						max_items = 8,
						score_offset = 15,
						opts = {
							insert = true,
						},
					},
					dictionary = {
						name = "Dict",
						module = "blink-cmp-dictionary",
						min_keyword_length = 3,
						max_items = 6,
						score_offset = 12,
						opts = {
							force_fallback = true,
							dictionary_directories = { dictionary_dir() },
						},
					},
					ripgrep = {
						name = "RG",
						module = "blink-ripgrep",
						min_keyword_length = 4,
						max_items = 5,
						async = true,
						score_offset = 10,
						opts = {
							prefix_min_len = 4,
							project_root_marker = ".git",
							fallback_to_regex_highlighting = true,
							backend = {
								use = "gitgrep-or-ripgrep",
								customize_icon_highlight = true,
								ripgrep = {
									context_size = 4,
									max_filesize = "1M",
									project_root_fallback = true,
									search_casing = "--smart-case",
									additional_paths = {},
									additional_rg_options = {},
									ignore_paths = {},
								},
							},
							gitgrep = {
								additional_gitgrep_options = {},
							},
							debug = false,
						},
					},
				},
			})

			opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
				enabled = true,
				keymap = {
					preset = "cmdline",
					["<CR>"] = { "accept_and_enter", "fallback" },
				},
				completion = {
					ghost_text = { enabled = true },
					menu = {
						auto_show = function()
							return vim.fn.getcmdtype() == ":"
						end,
					},
				},
			})

			opts.signature = {
				enabled = true,
				window = { border = border_style() },
			}

			opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				keyword = {
					range = "full",
				},
				trigger = {
					show_on_trigger_character = true,
					show_on_insert_on_trigger_character = true,
					show_on_accept_on_trigger_character = true,
				},
				ghost_text = {
					enabled = function()
						return not vim.tbl_contains({ "markdown", "text", "gitcommit" }, vim.bo.filetype)
					end,
				},
				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
				menu = {
					border = border_style(),
					auto_show = true,
					auto_show_delay_ms = function()
						if vim.bo.filetype == "markdown" then
							return 120
						end
						return 60
					end,
					draw = {
						columns = {
							{ "item_idx" },
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
						components = {
							item_idx = {
								text = function(ctx)
									if ctx.idx == 10 then
										return "0"
									end
									if ctx.idx > 10 then
										return " "
									end
									return tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx",
							},
							label = {
								width = { fill = true, max = 48 },
							},
							label_description = {
								width = { max = 32 },
							},
							kind_icon = {
								text = path_kind_icon,
								highlight = path_kind_highlight,
							},
							source_name = {
								width = { max = 8 },
								text = function(ctx)
									return "[" .. ctx.source_name .. "]"
								end,
								highlight = "BlinkCmpSource",
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 180,
					window = {
						border = border_style(),
					},
				},
			})

			return opts
		end,
	},
}
