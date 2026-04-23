local M = {}

local function has_client(bufnr, name)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client.name == name then
			return true
		end
	end

	return false
end

local function has_python_ruff_lsp(bufnr)
	return vim.bo[bufnr].filetype == "python" and has_client(bufnr, "ruff")
end

function M.linters_for_buffer(bufnr, linters_by_ft)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	linters_by_ft = linters_by_ft or {}

	local filetype = vim.bo[bufnr].filetype
	local linters = vim.deepcopy(linters_by_ft[filetype] or {})

	if has_python_ruff_lsp(bufnr) then
		linters = vim.tbl_filter(function(name)
			return name ~= "ruff"
		end, linters)
	end

	return linters
end

function M.clear_conflicting_diagnostics(lint, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not has_python_ruff_lsp(bufnr) then
		return
	end

	vim.diagnostic.reset(lint.get_namespace("ruff"), bufnr)
end

function M.should_lint(event, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return not (event == "BufEnter" and vim.bo[bufnr].filetype == "python")
end

function M.try_lint(lint, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local linters = M.linters_for_buffer(bufnr, lint.linters_by_ft)
	if #linters == 0 then
		M.clear_conflicting_diagnostics(lint, bufnr)
		return
	end

	lint.try_lint(linters)
end

return M
