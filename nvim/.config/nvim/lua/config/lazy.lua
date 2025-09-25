-- ~/.config/nvim/lua/config/lazy.lua
-- Настройка менеджера плагинов lazy.nvim

-- Автоматическая установка lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Настройка lazy.nvim
-- Он будет автоматически загружать все файлы .lua из директории lua/plugins/
require("lazy").setup({
	spec = {
		{ import = "plugins.move_and_navigation" },
		{ import = "plugins.lsp" },
		{ import = "plugins.editor" },
		{ import = "plugins.debug" },
		{ import = "plugins.latex" },
		{ import = "plugins.ui" },
		{ import = "plugins.ai" },
		{ import = "plugins.terminal" },
		{ import = "plugins.other" },
	},
})
