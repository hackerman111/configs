return {
	"MeanderingProgrammer/render-markdown.nvim",

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-mini/mini.nvim",
	},

	---@module "render-markdown"
	---@type render.md.UserConfig
	opts = {
		-- Markdown остаётся отрендеренным даже на строке курсора.
		anti_conceal = {
			enabled = false,
		},

		-- Особенно полезно для LSP/help/preview nofile buffers.
		overrides = {
			buftype = {
				nofile = {
					render_modes = true,

					anti_conceal = {
						enabled = false,
					},
				},
			},
		},
	},
}
