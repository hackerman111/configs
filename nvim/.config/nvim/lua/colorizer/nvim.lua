local function flatten(items, result)
	result = result or {}
	for _, item in ipairs(items) do
		if type(item) == "table" then
			flatten(item, result)
		else
			table.insert(result, item)
		end
	end
	return result
end

local function nvim_print(...)
	if select("#", ...) == 1 then
		vim.api.nvim_out_write(vim.inspect((...)))
	else
		vim.api.nvim_out_write(vim.inspect({ ... }))
	end
	vim.api.nvim_out_write("\n")
end

local function nvim_echo(...)
	for i = 1, select("#", ...) do
		local part = select(i, ...)
		vim.api.nvim_out_write(tostring(part))
		vim.api.nvim_out_write(" ")
	end
	vim.api.nvim_out_write("\n")
end

local window_options = {
	arab = true,
	arabic = true,
	breakindent = true,
	breakindentopt = true,
	bri = true,
	briopt = true,
	cc = true,
	cocu = true,
	cole = true,
	colorcolumn = true,
	concealcursor = true,
	conceallevel = true,
	crb = true,
	cuc = true,
	cul = true,
	cursorbind = true,
	cursorcolumn = true,
	cursorline = true,
	diff = true,
	fcs = true,
	fdc = true,
	fde = true,
	fdi = true,
	fdl = true,
	fdm = true,
	fdn = true,
	fdt = true,
	fen = true,
	fillchars = true,
	fml = true,
	fmr = true,
	foldcolumn = true,
	foldenable = true,
	foldexpr = true,
	foldignore = true,
	foldlevel = true,
	foldmarker = true,
	foldmethod = true,
	foldminlines = true,
	foldnestmax = true,
	foldtext = true,
	lbr = true,
	lcs = true,
	linebreak = true,
	list = true,
	listchars = true,
	nu = true,
	number = true,
	numberwidth = true,
	nuw = true,
	previewwindow = true,
	pvw = true,
	relativenumber = true,
	rightleft = true,
	rightleftcmd = true,
	rl = true,
	rlc = true,
	rnu = true,
	scb = true,
	scl = true,
	scr = true,
	scroll = true,
	scrollbind = true,
	signcolumn = true,
	spell = true,
	statusline = true,
	stl = true,
	wfh = true,
	wfw = true,
	winbl = true,
	winblend = true,
	winfixheight = true,
	winfixwidth = true,
	winhighlight = true,
	winhl = true,
	wrap = true,
}

return setmetatable({
	print = nvim_print,
	echo = nvim_echo,
	fn = setmetatable({}, {
		__index = function(self, key)
			local mt = getmetatable(self)
			local cached = mt[key]
			if cached ~= nil then
				return cached
			end
			local fn = function(...)
				return vim.api.nvim_call_function(key, { ... })
			end
			mt[key] = fn
			return fn
		end,
	}),
	buf = setmetatable({}, {
		__index = function(self, key)
			local mt = getmetatable(self)
			local cached = mt[key]
			if cached ~= nil then
				return cached
			end
			local fn
			if key == "line" then
				fn = function()
					local pos = vim.api.nvim_win_get_cursor(0)
					return vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
				end
			elseif key == "nr" then
				fn = vim.api.nvim_get_current_buf
			end
			mt[key] = fn
			return fn
		end,
	}),
	ex = setmetatable({}, {
		__index = function(self, key)
			local mt = getmetatable(self)
			local cached = mt[key]
			if cached ~= nil then
				return cached
			end
			local command = key:gsub("_$", "!")
			local fn = function(...)
				return vim.api.nvim_command(table.concat(flatten({ command, ... }), " "))
			end
			mt[key] = fn
			return fn
		end,
	}),
	g = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_get_var(key)
		end,
		__newindex = function(_, key, value)
			if value == nil then
				return vim.api.nvim_del_var(key)
			end
			return vim.api.nvim_set_var(key, value)
		end,
	}),
	v = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_get_vvar(key)
		end,
		__newindex = function(_, key, value)
			return vim.api.nvim_set_vvar(key, value)
		end,
	}),
	b = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_buf_get_var(0, key)
		end,
		__newindex = function(_, key, value)
			if value == nil then
				return vim.api.nvim_buf_del_var(0, key)
			end
			return vim.api.nvim_buf_set_var(0, key, value)
		end,
	}),
	w = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_win_get_var(0, key)
		end,
		__newindex = function(_, key, value)
			if value == nil then
				return vim.api.nvim_win_del_var(0, key)
			end
			return vim.api.nvim_win_set_var(0, key, value)
		end,
	}),
	o = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_get_option(key)
		end,
		__newindex = function(_, key, value)
			return vim.api.nvim_set_option(key, value)
		end,
	}),
	bo = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_buf_get_option(0, key)
		end,
		__newindex = function(_, key, value)
			return vim.api.nvim_buf_set_option(0, key, value)
		end,
	}),
	wo = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_win_get_option(0, key)
		end,
		__newindex = function(_, key, value)
			return vim.api.nvim_win_set_option(0, key, value)
		end,
	}),
	env = setmetatable({}, {
		__index = function(_, key)
			return vim.api.nvim_call_function("getenv", { key })
		end,
		__newindex = function(_, key, value)
			return vim.api.nvim_call_function("setenv", { key, value })
		end,
	}),
}, {
	__index = function(self, key)
		local mt = getmetatable(self)
		local cached = mt[key]
		if cached ~= nil then
			return cached
		end
		local api_fn = vim.api["nvim_" .. key]
		mt[key] = api_fn
		return api_fn
	end,
})
