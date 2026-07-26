---@type vim.lsp.Config
return {
	settings = {
		["rust-analyzer"] = {
			-- Более полная проверка, чем обычный cargo check.
			check = {
				command = "clippy",
				allTargets = true,
			},

			inlayHints = {
				-- Полезны при длинных цепочках методов.
				chainingHints = {
					enable = true,
				},

				-- Имена аргументов в местах вызова.
				parameterHints = {
					enable = true,
				},

				-- Выведенные типы локальных переменных.
				typeHints = {
					enable = true,
					hideClosureInitialization = true,
				},

				-- Подписи для закрывающих скобок длинных блоков.
				closingBraceHints = {
					enable = true,
					minLines = 20,
				},

				-- Не раздувать длинные обобщённые типы.
				maxLength = 40,
			},
		},
	},
}
