---@type vim.lsp.Config
return {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name

			-- Не вмешиваемся в обычный Lua-проект с собственной конфигурацией.
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
			runtime = {
				version = "LuaJIT",

				-- Пути загрузки модулей Neovim.
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},

			diagnostics = {
				globals = {
					"vim",
				},
			},

			workspace = {
				checkThirdParty = false,

				-- Типы встроенного API Neovim.
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,

	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},

			-- Форматирование выполняет Stylua через Conform.
			format = {
				enable = false,
			},

			hint = {
				enable = true,
				semicolon = "Disable",
			},

			telemetry = {
				enable = false,
			},
		},
	},
}
