---@type vim.lsp.Config

local function project_python(params)
	local root_uri = params.rootUri

	if type(root_uri) ~= "string" then
		return nil
	end

	local root = vim.uri_to_fname(root_uri)

	local candidates = {
		vim.fs.joinpath(root, ".venv", "bin", "python"),
		vim.fs.joinpath(root, "venv", "bin", "python"),
	}

	for _, python in ipairs(candidates) do
		if vim.fn.executable(python) == 1 then
			return python
		end
	end

	return nil
end

return {
	init_options = {
		-- Нормальное форматирование docstring в hover.
		markupKindPreferred = "markdown",

		-- Диагностику делает ty.
		diagnostics = {
			enable = false,
		},

		hover = {
			enable = true,
		},

		-- У тебя уже есть Treesitter/LSP highlighting.
		semanticTokens = {
			enable = false,
		},
	},

	before_init = function(params)
		local python = project_python(params)

		if not python then
			-- Тогда Jedi использует активный Python environment.
			return
		end

		params.initializationOptions = params.initializationOptions or {}

		params.initializationOptions.workspace = params.initializationOptions.workspace or {}

		params.initializationOptions.workspace.environmentPath = python
	end,
}
