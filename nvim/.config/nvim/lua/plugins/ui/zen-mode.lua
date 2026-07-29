local ui = require("config.ui")

return {
	"folke/zen-mode.nvim",

	opts = {
		plugins = {
			tmux = {
				enabled = true,
			},
		},

		on_open = function()
			ui.set_opaque(true)

			if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
				vim.system({
					"hyprctl",
					"dispatch",
					"fullscreen",
					"0",
					"set",
				})
			end
		end,

		on_close = function()
			ui.set_opaque(false)

			if vim.env.HYPRLAND_INSTANCE_SIGNATURE then
				vim.system({
					"hyprctl",
					"dispatch",
					"fullscreen",
					"0",
					"unset",
				})
			end
		end,
	},
}
