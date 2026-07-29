vim.opt.termguicolors = true
vim.opt.fillchars:append({ eob = " " })

local M = {}

local opaque = true

local transparent_groups = {
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
}

local function make_transparent()
	for _, group in ipairs(transparent_groups) do
		vim.cmd(("highlight %s guibg=NONE ctermbg=NONE"):format(group))
	end
end

function M.set_opaque(value)
	opaque = value

	if opaque then
		-- Повторно загружаем тему и возвращаем её стандартный фон.
		vim.cmd.colorscheme("nord")
	else
		make_transparent()
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("NvimTransparency", { clear = true }),
	callback = function()
		if not opaque then
			vim.schedule(make_transparent)
		end
	end,
})

-- Обычное состояние Neovim: прозрачное.
M.set_opaque(false)

return M
