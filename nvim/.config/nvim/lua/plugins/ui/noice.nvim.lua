-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/noice.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/noice.lua

-- I want to change the default notifications to be less obtrussive (if that's even a word)
-- https://github.com/folke/noice.nvim

return {
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				config = function()
					require("notify").setup(require("config.ui").notify_opts())
				end,
			},
		},
		event = "VeryLazy",
		opts = function()
			return require("config.ui").noice_opts()
		end,
	},
}
