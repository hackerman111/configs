return {
	{ "tpope/vim-fugitive" },
	{ "numToStr/Comment.nvim", opts = {} },
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
		config = function()
			local map = vim.keymap.set
			local opts = { silent = true, noremap = true }

			map("n", "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>", vim.tbl_extend("force", opts, { desc = "Перейти в окно слева" }))
			map("n", "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>", vim.tbl_extend("force", opts, { desc = "Перейти в окно снизу" }))
			map("n", "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>", vim.tbl_extend("force", opts, { desc = "Перейти в окно сверху" }))
			map("n", "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>", vim.tbl_extend("force", opts, { desc = "Перейти в окно справа" }))
			map("n", "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<CR>", vim.tbl_extend("force", opts, { desc = "Вернуться в предыдущее окно" }))
		end,
	},
	{
		"lyokha/vim-xkbswitch",
		init = function()
			vim.g.XkbSwitchEnabled = 1
			vim.g.XkbSwitchIMappings = { "ru" }
		end,
	},
}
