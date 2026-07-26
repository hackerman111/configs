vim.opt.termguicolors = true

local function transparent_nvim()
	for _, group in ipairs({
		"Normal",
		"NormalNC",
		"SignColumn",
		"LineNr",
		"CursorLineNr",
		"FoldColumn",
		"NormalFloat",
		"FloatBorder",
		"Pmenu",
		"StatusLine",
		"StatusLineNC",
		"WinSeparator",
	}) do
		vim.api.nvim_set_hl(0, group, { bg = "none" })
	end
end

transparent_nvim()
vim.opt.fillchars:append({ eob = " " })

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = transparent_nvim,
})
