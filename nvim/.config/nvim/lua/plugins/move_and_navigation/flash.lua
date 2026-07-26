local function escape_vim_pattern(text)
	return vim.fn.escape(text, [[\]])
end

local function flash_word_jump(kind)
	local flash = require("flash")

	flash.jump({
		search = {
			mode = function(str)
				local escaped = escape_vim_pattern(str)
				return [[\<\k*\V]] .. escaped .. [[\m\k*\>]]
			end,
		},
		jump = {
			pos = kind == "end" and "end" or "start",
		},
	})
end

local function leap_ft(key_specific_args)
	require("leap").leap(vim.tbl_deep_extend("keep", key_specific_args, {
		inputlen = 1,
		inclusive = true,
		opts = {
			labels = "",
			safe_labels = vim.fn.mode(1):match("o") and "" or nil,
		},
	}))
end

return {
	{
		url = "https://codeberg.org/andyg/leap.nvim",
		lazy = false,
		dependencies = { "tpope/vim-repeat" },
		config = function()
			local clever = require("leap.user").with_traversal_keys
			local clever_f = clever("f", "F")
			local clever_t = clever("t", "T")

			require("leap").opts.preview = function(ch0, ch1, ch2)
				return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
			end

			vim.keymap.set({ "n", "x", "o" }, "zs", "<Plug>(leap)", { desc = "Leap: jump in window" })
			vim.keymap.set({ "n", "x", "o" }, "zS", "<Plug>(leap-anywhere)", { desc = "Leap: jump anywhere" })

			vim.keymap.set({ "n", "x", "o" }, "f", function()
				leap_ft({ opts = clever_f })
			end, { desc = "Leap: find character forward" })
			vim.keymap.set({ "n", "x", "o" }, "F", function()
				leap_ft({ backward = true, opts = clever_f })
			end, { desc = "Leap: find character backward" })
			vim.keymap.set({ "n", "x", "o" }, "t", function()
				leap_ft({ offset = -1, opts = clever_t })
			end, { desc = "Leap: till character forward" })
			vim.keymap.set({ "n", "x", "o" }, "T", function()
				leap_ft({ backward = true, offset = 1, opts = clever_t })
			end, { desc = "Leap: till character backward" })
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			search = {
				multi_window = true,
				wrap = true,
			},
			modes = {
				search = {
					enabled = false,
					highlight = { backdrop = false },
					jump = { history = true, register = true, nohlsearch = true },
				},
				char = {
					enabled = false,
				},
				treesitter = {
					labels = "abcdefghijklmnopqrstuvwxyz",
					jump = { pos = "range", autojump = true },
					search = { incremental = false },
					label = { before = true, after = true, style = "inline" },
					highlight = {
						backdrop = false,
						matches = false,
					},
				},
				treesitter_search = {
					jump = { pos = "range" },
					search = { multi_window = true, wrap = true, incremental = false },
					remote_op = { restore = true },
					label = { before = true, after = true, style = "inline" },
				},
				remote = {
					remote_op = { restore = true, motion = true },
				},
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash: fast jump",
			},
			{
				"gw",
				mode = { "n", "x", "o" },
				function()
					flash_word_jump("start")
				end,
				desc = "Flash: jump to word start",
			},
			{
				"ge",
				mode = { "n", "x", "o" },
				function()
					flash_word_jump("end")
				end,
				desc = "Flash: jump to word end",
			},
			{
				"gm",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						search = { mode = "exact" },
					})
				end,
				desc = "Flash: jump to typed text",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash: structure selection",
			},
			{
				"R",
				mode = { "x", "o" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Flash: structure search",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Flash: remote edit jump",
			},
			{
				"<C-s>",
				mode = "c",
				function()
					require("flash").toggle()
				end,
				desc = "Flash: toggle search labels",
			},
		},
	},
}
