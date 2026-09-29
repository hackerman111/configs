vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.mapleader = " "

if vim.g.vscode then
	require("vscode-nvim.ipynb")
	require("vscode-nvim.notebook_nav")
else
	require("config.lazy")
	require("config.ui")
	require("config.keymaps")
	require("config.options")
end
