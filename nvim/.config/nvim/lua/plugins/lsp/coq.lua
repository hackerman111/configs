local completion = require("config.completion")

local function coq_enabled()
	return completion.is_coq()
end

local function pum_visible()
	return vim.fn.pumvisible() == 1
end

local function pum_cancel(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, {
		expr = true,
		silent = true,
		replace_keycodes = true,
		desc = "COQ completion compatibility",
	})
end

return {
	{
		"ms-jpq/coq_nvim",
		branch = "coq",
		lazy = false,
		build = ":COQdeps",
		enabled = coq_enabled,
		dependencies = {
			{ "ms-jpq/coq.artifacts", branch = "artifacts" },
			{ "ms-jpq/coq.thirdparty", branch = "3p" },
			{ "zbirenbaum/copilot.lua" },
		},
		init = function()
			vim.g.coq_settings = {
				auto_start = "shut-up",
				xdg = true,
				completion = {
					skip_after = { " ", "\t", "\n" },
					sticky_manual = false,
					always = true,
				},
				keymap = {
					recommended = false,
				},
				display = {
					icons = {
						mode = "short",
					},
					ghost_text = {
						enabled = true,
						context = { " ", "" },
					},
					preview = {
						border = "rounded",
						resolve_timeout = 0.08,
					},
					pum = {
						fast_close = false,
						y_ratio = 0.2,
						y_max_len = 10,
					},
				},
				limits = {
					completion_auto_timeout = 0.2,
					completion_manual_timeout = 0.8,
				},
				clients = {
					lsp = {
						enabled = true,
						resolve_timeout = 0.12,
					},
					tree_sitter = {
						enabled = true,
						weight_adjust = 1.1,
					},
					third_party = {
						enabled = true,
						always_on_top = { "COP" },
						weight_adjust = 0.8,
					},
					registers = {
						words = { "0", "a", "b" },
						lines = { "a", "b", "c" },
					},
				},
			}
		end,
		config = function()
			require("coq_3p")({
				{ src = "nvimlua", short_name = "nLUA", conf_only = true },
				{ src = "vimtex", short_name = "vTEX" },
				{ src = "copilot_lua", short_name = "COP", max_items = 3 },
			})

			pum_cancel("<Esc>", function()
				return pum_visible() and "<C-e><Esc>" or "<Esc>"
			end)
			pum_cancel("<C-c>", function()
				return pum_visible() and "<C-e><C-c>" or "<C-c>"
			end)
			pum_cancel("<BS>", function()
				return pum_visible() and "<C-e><BS>" or "<BS>"
			end)
			pum_cancel("<CR>", function()
				if not pum_visible() then
					return "<CR>"
				end

				local info = vim.fn.complete_info({ "selected" })
				return info.selected == -1 and "<C-e><CR>" or "<C-y>"
			end)
		end,
	},
}
