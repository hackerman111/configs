return {
	{
		dir = "/home/papayka/AMI/vscode", -- локальный путь (или URL git-репозитория при публикации)
		name = "vscode-ipynb-vim",
		cond = vim.g.vscode ~= nil,
		opts = {},
	},
}
