-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua

-- HACK: blink.cmp updates | Remove LuaSnip | Emoji and Dictionary Sources | Fix Jump Autosave Issue
-- https://youtu.be/JrgfpWap_Pg
-- completion plugin with support for LSPs and external sources that updates
-- on every keystroke with minimal overhead
-- https://www.lazyvim.org/extras/coding/blink
-- https://github.com/saghen/blink.cmp
-- Documentation site: https://cmp.saghen.dev/
-- NOTE: Specify the trigger character(s) used for luasnip

local trigger_text = ";"
return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		enabled = true,
		-- In case there are breaking changes and you want to go back to the last
		-- working release
		-- https://github.com/Saghen/blink.cmp/releases
		dependencies = {
			"L3MON4D3/LuaSnip",
			"moyiz/blink-emoji.nvim",
			"onsails/lspkind.nvim",
			"Kaiser-Yang/blink-cmp-dictionary",
			"fang2hou/blink-copilot",
			"mikavilpas/blink-ripgrep.nvim",
		},

		opts = function(_, opts)
			-- I noticed that telescope was extremeley slow and taking too long to open,
			-- assumed related to blink, so disabled blink and in fact it was related
			-- :lua print(vim.bo[0].filetype)
			-- So I'm disabling blink.cmp for Telescope

			opts.enabled = function()
				-- Get the current buffer's filetype
				local filetype = vim.bo[0].filetype
				-- Disable for Telescope buffers

				if
					filetype == "TelescopePrompt"
					or filetype == "minifiles"
					or filetype == "snacks_picker_input"
					or filetype == "tex"
				then
					return false
				end
				return true
			end
			-- NOTE: The new way to enable LuaSnip
			-- Merge custom sources with the existing ones from lazyvim
			-- NOTE: by default lazyvim already includes the lazydev source, so not adding it here again
			opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
				-- The trigger_characters option is removed from here as we want snippets to show always

				default = {
					"lsp",
					"path",
					"buffer",
					"emoji",
					"dictionary",
					"copilot",
					"ripgrep",
				},
				providers = {
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						-- see the full configuration below for all available options
						---@module "blink-ripgrep"
						---@type blink-ripgrep.Options
						opts = {
							prefix_min_len = 2,
						},
					},

					copilot = {
						name = "copilot",
						module = "blink-copilot",
						min_keyword_length = 2,
						score_offset = 90,
						async = true,
					},
					lsp = {
						name = "lsp",
						enabled = true,
						module = "blink.cmp.sources.lsp",
						min_keyword_length = 1,
						-- When linking markdown notes, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no LSP
						-- suggestions
						--
						-- Enabled fallbacks as this seems to be working now
						-- Disabling fallbacks as my snippets wouldn't show up when editing
						-- lua files
						-- fallbacks = { "snippets", "buffer" },
						score_offset = 100, -- the higher the number, the higher the priority
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = 100,
						-- When typing a path, I would get snippets and text in the
						-- suggestions, I want those to show only if there are no path
						-- suggestions
						fallbacks = { "snippets", "buffer" },
						min_keyword_length = 2,
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
						name = "Buffer",
						enabled = true,
						max_items = 3,
						module = "blink.cmp.sources.buffer",
						min_keyword_length = 2,
						score_offset = 15, -- the higher the number, the higher the priority
					},
					-- Example on how to configure dadbod found in the main repo
					-- https://github.com/kristijanhusak/vim-dadbod-completion
					dadbod = {
						name = "Dadbod",
						module = "vim_dadbod_completion.blink",
						min_keyword_length = 2,
						score_offset = 85, -- the higher the number, the higher the priority
					},
					-- https://github.com/moyiz/blink-emoji.nvim
					emoji = {
						module = "blink-emoji",
						name = "Emoji",
						score_offset = 89, -- the higher the number, the higher the priority
						min_keyword_length = 2,
						opts = { insert = true }, -- Insert emoji (default) or complete its name
					},
					-- https://github.com/Kaiser-Yang/blink-cmp-dictionary
					-- In macOS to get started with a dictionary:
					-- cp /usr/share/dict/words ~/github/dotfiles-latest/dictionaries/words.txt
					--
					-- NOTE: For the word definitions make sure "wn" is installed
					-- brew install wordnet
					dictionary = {
						module = "blink-cmp-dictionary",
						name = "Dict",
						score_offset = 20, -- the higher the number, the higher the priority
						-- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
						enabled = true,
						max_items = 8,
						min_keyword_length = 3,
						opts = {
							-- -- The dictionary by default now uses fzf, make sure to have it
							-- -- installed
							-- -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
							--
							-- Do not specify a file, just the path, and in the path you need to
							-- have your .txt files
							dictionary_directories = { vim.fn.expand("~/github/dotfiles-latest/dictionaries") },
							-- Notice I'm also adding the words I add to the spell dictionary
							dictionary_files = {
								vim.fn.expand("~/github/dotfiles-latest/neovim/neobean/spell/en.utf-8.add"),
								vim.fn.expand("~/github/dotfiles-latest/neovim/neobean/spell/es.utf-8.add"),
							},
							-- --  NOTE: To disable the definitions uncomment this section below
							--
							-- separate_output = function(output)
							--   local items = {}
							--   for line in output:gmatch("[^\r\n]+") do
							--     table.insert(items, {
							--       label = line,
							--       insert_text = line,
							--       documentation = nil,
							--     })
							--   end
							--   return items
							-- end,
						},
					},
					-- -- Third class citizen mf always talking shit
					-- copilot = {
					--   name = "copilot",
					--   enabled = true,
					--   module = "blink-cmp-copilot",
					--   kind = "Copilot",
					--   min_keyword_length = 6,
					--   score_offset = -100, -- the higher the number, the higher the priority
					--   async = true,
					-- },
				},
			})
			opts.cmdline = {
				enabled = true,
			}
			opts.completion = {
				accept = {
					auto_brackets = {
						enabled = true,
						--default_brackets = { ";", "" },
						--override_brackets_for_filetypes = {
						--	markdown = { ";", "" },
						--},
					},
				},
				--   keyword = {
				--     -- 'prefix' will fuzzy match on the text before the cursor
				--     -- 'full' will fuzzy match on the text before *and* after the cursor
				--     -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
				--     range = "full",
				--   },
				ghost_text = { enabled = true },
				menu = {
					border = "single",
					draw = {
						components = {
							kind_icon = {
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end

									return icon .. ctx.icon_gap
								end,

								-- Optionally, use the highlight groups from nvim-web-devicons
								-- You can also add the same function for `kind.highlight` if you want to
								-- keep the highlight groups in sync with the icons.
								highlight = function(ctx)
									local hl = ctx.kind_hl
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end
									return hl
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = true,
					window = {
						border = "single",
					},
				},
				list = {
					selection = {
						preselect = true,
						auto_insert = true,
					},
				},
			}
			-- opts.fuzzy = {
			--   -- Disabling this matches the behavior of fzf
			--   use_typo_resistance = false,
			--   -- Frecency tracks the most recently/frequently used items and boosts the score of the item
			--   use_frecency = true,
			--   -- Proximity bonus boosts the score of items matching nearby words
			--   use_proximity = false,
			-- }
			-- -- To specify the options for snippets
			-- opts.sources.providers.snippets.opts = {
			--   use_show_condition = true, -- Enable filtering of snippets dynamically
			--   show_autosnippets = true, -- Display autosnippets in the completion menu
			-- }
			-- The default preset used by lazyvim accepts completions with enter
			-- I don't like using enter because if on markdown and typing
			-- something, but you want to go to the line below, if you press enter,
			-- the completion will be accepted
			-- https://cmp.saghen.dev/configuration/keymap.html#default

			opts.keymap = {
				preset = "enter",
			}
			return opts
		end,
	},
	{
		"saghen/blink.pairs",
		version = "*", -- (recommended) only required with prebuilt binaries

		-- download prebuilt binaries from github releases
		dependencies = "saghen/blink.download",
		-- OR build from source, requires nightly:
		-- https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		--- @module 'blink.pairs'
		--- @type blink.pairs.Config
		opts = {},
	},
}
