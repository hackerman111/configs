return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("trouble").setup({
			modes = {
				diagnostics = {
					auto_open = false,
					auto_close = true,
				},
			},
			warn_no_results = false,
		})
	end,
	keys = {
		{
			"<leader>tt",
			"<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
			desc = "Диагностика текущего файла",
		},
		{
			"<leader>tT",
			"<cmd>Trouble diagnostics toggle focus=true<cr>",
			desc = "Диагностика проекта",
		},
		{
			"<leader>ts",
			"<cmd>Trouble symbols toggle focus=true<cr>",
			desc = "Символы текущего файла",
		},
	},
}
