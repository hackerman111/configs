local M = {}

local root_markers = {
	"pyproject.toml",
	"uv.lock",
	"requirements.txt",
	"setup.py",
	".git",
}

local function project_root(buf)
	return vim.fs.root(buf, root_markers) or vim.fn.getcwd()
end

local function python_for_buffer(buf)
	local root = project_root(buf)

	local candidates = {}

	if vim.env.VIRTUAL_ENV then
		table.insert(candidates, vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python"))
	end

	table.insert(candidates, vim.fs.joinpath(root, ".venv", "bin", "python"))

	table.insert(candidates, vim.fs.joinpath(root, "venv", "bin", "python"))

	for _, python in ipairs(candidates) do
		if vim.fn.executable(python) == 1 then
			return python
		end
	end

	local python3 = vim.fn.exepath("python3")

	if python3 ~= "" then
		return python3
	end

	return "python"
end

local function expression_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	local left = line:sub(1, col):match("([%a_][%w_%.]*)$") or ""

	local right = line:sub(col + 1):match("^([%w_%.]*)") or ""

	return left .. right
end

local function resolve_import_alias(buf, symbol)
	local first = symbol:match("^([%a_][%w_]*)")

	if not first then
		return symbol
	end

	local suffix = symbol:sub(#first + 1)

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for _, line in ipairs(lines) do
		-- import numpy as np
		local module, alias = line:match("^%s*import%s+([%w_%.]+)%s+as%s+([%w_]+)")

		if alias == first then
			return module .. suffix
		end

		-- from torch.nn import functional as F
		local from_module, name, from_alias =
			line:match("^%s*from%s+([%w_%.]+)%s+import%s+" .. "([%w_]+)%s+as%s+([%w_]+)")

		if from_alias == first then
			return from_module .. "." .. name .. suffix
		end

		-- from numpy.linalg import svd
		local plain_module, plain_name = line:match("^%s*from%s+([%w_%.]+)%s+import%s+([%w_]+)")

		if plain_name == first then
			return plain_module .. "." .. plain_name .. suffix
		end
	end

	return symbol
end

local function open_documentation(target, text)
	vim.cmd("botright 20new")

	local buf = vim.api.nvim_get_current_buf()

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "text"

	pcall(vim.api.nvim_buf_set_name, buf, "pydoc://" .. target)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n", { plain = true }))

	vim.bo[buf].modifiable = false

	vim.keymap.set("n", "q", "<cmd>close<CR>", {
		buffer = buf,
		silent = true,
	})
end

function M.show(target)
	local buf = vim.api.nvim_get_current_buf()

	target = target or expression_under_cursor()
	target = resolve_import_alias(buf, target)

	if not target or target == "" then
		vim.notify("Не удалось определить Python symbol", vim.log.levels.WARN)
		return
	end

	local python = python_for_buffer(buf)

	local script = [[
import pydoc
import sys

print(
    pydoc.render_doc(
        sys.argv[1],
        renderer=pydoc.plaintext,
    )
)
]]

	vim.system({
		python,
		"-c",
		script,
		target,
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				vim.notify(result.stderr ~= "" and result.stderr or ("pydoc failed: " .. target), vim.log.levels.ERROR)
				return
			end

			open_documentation(target, result.stdout)
		end)
	end)
end

function M.setup()
	if vim.g.user_pydoc_loaded then
		return
	end

	vim.g.user_pydoc_loaded = true

	vim.api.nvim_create_user_command("PyDoc", function(opts)
		local target = opts.args ~= "" and opts.args or nil

		M.show(target)
	end, {
		nargs = "?",
	})

	vim.keymap.set("n", "<leader>pd", function()
		M.show()
	end, {
		desc = "Python runtime documentation",
	})
end

function M.show(target)
	local buf = vim.api.nvim_get_current_buf()

	target = target or expression_under_cursor()
	target = resolve_import_alias(buf, target)

	if not target or target == "" then
		vim.cmd("Lspsaga hover_doc")
		return
	end

	-- self.*, cls.* и обычные локальные переменные pydoc
	-- принципиально не может разрешить как importable object.
	if target:match("^self%.") or target:match("^cls%.") or not target:find("%.") then
		vim.cmd("Lspsaga hover_doc")
		return
	end

	local python = python_for_buffer(buf)

	local script = [[
import pydoc
import sys

try:
    text = pydoc.render_doc(
        sys.argv[1],
        renderer=pydoc.plaintext,
    )
except Exception:
    sys.exit(2)

print(text)
]]

	vim.system({
		python,
		"-c",
		script,
		target,
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				-- pydoc ничего не нашёл:
				-- возвращаемся к ty/Jedi/LSP.
				vim.cmd("Lspsaga hover_doc")
				return
			end

			if not result.stdout or result.stdout == "" then
				vim.cmd("Lspsaga hover_doc")
				return
			end

			open_documentation(target, result.stdout)
		end)
	end)
end

return M
