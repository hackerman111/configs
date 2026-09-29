local M = {}

function M.resolve_python()
	local env = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
	if env then
		local python = vim.fs.joinpath(env, "bin", "python")
		if vim.fn.executable(python) == 1 then
			return python
		end
	end

	local root = vim.fs.root(0, { "pyproject.toml", "setup.py", "requirements.txt", ".git" }) or vim.fn.getcwd()
	for _, dir in ipairs({ ".venv", "venv", "env" }) do
		local python = vim.fs.joinpath(root, dir, "bin", "python")
		if vim.fn.executable(python) == 1 then
			return python
		end
	end

	local python = vim.fn.exepath("python3")
	return python ~= "" and python or "python3"
end

return M
