local M = {}

local severity = vim.diagnostic.severity

local function trim(text)
	return (text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function to_hex(color)
	if not color then
		return nil
	end

	return string.format("#%06x", color)
end

local function highlight_color(name, field, fallback)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok or type(hl) ~= "table" then
		return fallback
	end

	return to_hex(hl[field]) or fallback
end

function M.strip_statusline_hl(text)
	return trim((text or ""):gsub("%%#.-#", ""):gsub("%%##", ""))
end

function M.format_diagnostic_message(diagnostic)
	local message = trim(diagnostic.message)
	if message == "" then
		return nil
	end

	return message
end

function M.virtual_text_prefix(_, index, _)
	return index == 1 and "●" or "·"
end

function M.apply_core_options()
	vim.o.winborder = "rounded"
	vim.o.pumborder = "rounded"
	vim.o.messagesopt = "hit-enter,history:500,progress:c"
end

function M.diagnostic_config()
	return {
		virtual_text = {
			spacing = 2,
			source = "if_many",
			current_line = false,
			severity = { min = severity.WARN },
			prefix = M.virtual_text_prefix,
			format = M.format_diagnostic_message,
		},
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		float = {
			source = "if_many",
		},
		signs = {
			text = {
				[severity.ERROR] = "󰅚 ",
				[severity.WARN] = "󰀪 ",
				[severity.INFO] = "󰋽 ",
				[severity.HINT] = "󰌶 ",
			},
			numhl = {
				[severity.ERROR] = "ErrorMsg",
				[severity.WARN] = "WarningMsg",
			},
		},
	}
end

function M.lualine_diagnostic_status()
	local status = M.strip_statusline_hl(vim.diagnostic.status())
	return status ~= "" and status or nil
end

function M.lualine_progress_status()
	local status = trim(vim.ui.progress_status())
	return status ~= "" and status or nil
end

function M.lualine_lsp_status()
	if M.lualine_progress_status() ~= nil then
		return nil
	end

	local names = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		names[client.name] = true
	end

	local ordered = {}
	for name in pairs(names) do
		table.insert(ordered, name)
	end
	table.sort(ordered)

	if #ordered == 0 then
		return nil
	end

	return "LSP " .. table.concat(ordered, ", ")
end

function M.lualine_opts()
	return {
		options = {
			theme = "nord",
			globalstatus = true,
			icons_enabled = true,
			component_separators = { left = "·", right = "·" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {
					"alpha",
					"checkhealth",
					"help",
					"lazy",
					"mason",
					"oil",
					"qf",
					"snacks_dashboard",
					"Trouble",
					"trouble",
				},
				winbar = {},
			},
			always_divide_middle = true,
		},
		sections = {
			lualine_a = {
				{
					"mode",
					fmt = function(mode)
						return mode:upper()
					end,
				},
			},
			lualine_b = {
				"branch",
				{
					"diff",
					symbols = { added = "+", modified = "~", removed = "-" },
				},
			},
			lualine_c = {
				{
					"filename",
					path = 1,
					file_status = true,
					newfile_status = true,
					shorting_target = 48,
					symbols = {
						modified = " [+]",
						readonly = " [-]",
						unnamed = "[No Name]",
						newfile = " [New]",
					},
				},
			},
			lualine_x = {
				{ M.lualine_diagnostic_status },
				{ M.lualine_progress_status },
			},
			lualine_y = {
				{ M.lualine_lsp_status },
			},
			lualine_z = { "location", "progress" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {
				{
					"filename",
					path = 1,
					file_status = true,
				},
			},
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
	}
end

function M.snacks_opts()
	return {
		input = {
			enabled = true,
			win = {
				relative = "cursor",
				backdrop = false,
				border = "rounded",
				title_pos = "center",
			},
		},
		picker = { enabled = true },
		styles = {
			input = {
				border = "rounded",
				title_pos = "center",
				wo = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder,FloatTitle:Title",
				},
			},
		},
	}
end

function M.incline_opts()
	return {
		highlight = {
			groups = {
				InclineNormal = {
					guibg = highlight_color("StatusLine", "bg", "#3b4252"),
					guifg = highlight_color("StatusLine", "fg", "#eceff4"),
				},
				InclineNormalNC = {
					guibg = highlight_color("StatusLineNC", "bg", "#2e3440"),
					guifg = highlight_color("Comment", "fg", "#81a1c1"),
				},
			},
		},
		window = { margin = { vertical = 0, horizontal = 1 } },
		hide = {
			cursorline = true,
		},
		render = function(props)
			local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
			if filename == "" then
				filename = "[No Name]"
			end

			if vim.bo[props.buf].modified then
				filename = "[+] " .. filename
			end

			local icon, color = require("nvim-web-devicons").get_icon_color(filename)
			return {
				{ icon or "", guifg = color or highlight_color("Directory", "fg", "#88c0d0") },
				{ " " },
				{ filename },
			}
		end,
	}
end

function M.notify_opts()
	return {
		render = "compact",
		stages = "fade_in_slide_out",
		timeout = 2500,
		background_colour = "#2e3440",
	}
end

function M.noice_opts()
	return {
		presets = {
			bottom_search = true,
			command_palette = false,
			long_message_to_split = true,
			lsp_doc_border = false,
		},
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			format = {
				cmdline = { icon = "" },
				search_down = { icon = " " },
				search_up = { icon = " " },
				filter = { icon = "$" },
				lua = { icon = "" },
				help = { icon = "" },
				input = { icon = "󰥻 " },
			},
		},
		messages = {
			enabled = true,
			view = "cmdline",
			view_error = "cmdline",
			view_warn = "cmdline",
			view_history = "messages",
			view_search = false,
		},
		popupmenu = {
			enabled = false,
		},
		notify = {
			enabled = true,
			view = "notify",
		},
		lsp = {
			progress = {
				enabled = false,
			},
			message = {
				enabled = false,
			},
			hover = {
				enabled = true,
				silent = true,
			},
			signature = {
				enabled = true,
				auto_open = {
					enabled = false,
					trigger = true,
					luasnip = true,
					throttle = 50,
				},
			},
		},
		views = {
			cmdline_popup = {
				position = {
					row = "40%",
					col = "50%",
				},
			},
		},
	}
end

return M
