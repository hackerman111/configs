local M = {}

function M.get_engine()
	local engine = vim.g.completion_engine
	if engine == "coq" then
		return "coq"
	end
	return "blink"
end

function M.is_blink()
	return M.get_engine() == "blink"
end

function M.is_coq()
	return M.get_engine() == "coq"
end

function M.get_lsp_capabilities(capabilities)
	if M.is_blink() then
		local ok, blink = pcall(require, "blink.cmp")
		if ok and type(blink.get_lsp_capabilities) == "function" then
			return blink.get_lsp_capabilities(capabilities)
		end
	end

	if M.is_coq() then
		local ok, coq = pcall(require, "coq")
		if ok and type(coq.lsp_ensure_capabilities) == "function" then
			return coq.lsp_ensure_capabilities(capabilities)
		end
	end

	return capabilities
end

return M
