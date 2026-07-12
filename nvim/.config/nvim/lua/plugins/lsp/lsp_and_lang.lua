-- ~/.config/nvim/lua/plugins/lsp_and_lang.lua
-- Плагины для LSP, автодополнения и поддержки языков

return {
	-- Автодополнение и LSP
	-- Подсветка синтаксиса

	{
		"mason-org/mason.nvim",
		opts = {},
	},

	{

		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "lua_ls", "ruff" },
			})
		end,
	},

	{
		lazy = false, -- REQUIRED: tell lazy.nvim to start this plugin at startup
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim" },
			-- 	{ "ms-jpq/coq_nvim", branch = "coq" },
			--
			-- 	{
			-- 		"ms-jpq/coq.thirdparty",
			-- 		config = function()
			-- 			require("coq_3p")({})
			-- 		end,
			-- 	},
		},
		-- --
		--
		-- init = function()
		-- 	vim.g.coq_settings = {
		-- 		completion = {
		--
		-- 			skip_after = { " " },
		-- 			sticky_manual = false,
		-- 			always = true,
		-- 		},
		-- 		auto_start = "shut-up",
		-- 		clients = {
		-- 			lsp = {
		-- 				enabled = true,
		-- 			},
		-- 			tree_sitter = {
		-- 				enabled = true,
		-- 				weight_adjust = 1.0,
		-- 			},
		-- 			--				copilot = { enabled = true },
		-- 		},
		-- 		keymap = {
		-- 			recommended = false,
		-- 		},
		-- 		display = {
		-- 			ghost_text = {
		-- 				--- chars surrounding the ghost_text for current selection item.
		-- 				context = { " ", "" },
		-- 			},
		-- 			preview = {
		-- 				border = "solid",
		-- 				resolve_timeout = 0.01,
		-- 				--					positions = "east",
		-- 			},
		-- 			pum = {
		-- 				fast_close = true,
		-- 				y_ratio = 0.1,
		-- 				y_max_len = 5,
		-- 			},
		-- 		},
		-- 	}
		-- 	vim.api.nvim_set_keymap(
		-- 		"i",
		-- 		"<Esc>",
		-- 		[[pumvisible() ? "\<C-e><Esc>" : "\<Esc>"]],
		-- 		{ expr = true, silent = true }
		-- 	)
		-- 	vim.api.nvim_set_keymap(
		-- 		"i",
		-- 		"<C-c>",
		-- 		[[pumvisible() ? "\<C-e><C-c>" : "\<C-c>"]],
		-- 		{ expr = true, silent = true }
		-- 	)
		-- 	vim.api.nvim_set_keymap(
		-- 		"i",
		-- 		"<BS>",
		-- 		[[pumvisible() ? "\<C-e><BS>" : "\<BS>"]],
		-- 		{ expr = true, silent = true }
		-- 	)
		-- 	vim.api.nvim_set_keymap(
		-- 		"i",
		-- 		"<CR>",
		-- 		[[pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"]],
		-- 		{ expr = true, silent = true }
		-- 	)
		-- end,
		opts = {
			servers = {
				lua_ls = {},
				rust_analyzer = {},
				clangd = {},
			},
		},
		config = function()
			config =
				function(_, opts)
					require("lspconfig.ui.windows").default_options.border = "rounded"

					local lspconfig = require("lspconfig")
					for server, config in pairs(opts.servers) do
						config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
						lspconfig[server].setup(config)
					end
				end,
				-- LSP servers are automatically managed by Mason
				-- Use :MasonVerify to check which tools are Mason-managed
				vim.diagnostic.config({
					virtual_text = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
					float = {
						border = "rounded",
						source = true,
					},
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = "󰅚 ",
							[vim.diagnostic.severity.WARN] = "󰀪 ",
							[vim.diagnostic.severity.INFO] = "󰋽 ",
							[vim.diagnostic.severity.HINT] = "󰌶 ",
						},
						numhl = {
							[vim.diagnostic.severity.ERROR] = "ErrorMsg",
							[vim.diagnostic.severity.WARN] = "WarningMsg",
						},
					},
				})

			-- Extras

			local function restart_lsp(bufnr)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				for _, client in ipairs(clients) do
					vim.lsp.stop_client(client.id)
				end

				vim.defer_fn(function()
					vim.cmd("edit")
				end, 100)
			end

			vim.api.nvim_create_user_command("LspRestart", function()
				restart_lsp()
			end, {})

			local function lsp_status()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				if #clients == 0 then
					print("󰅚 No LSP clients attached")
					return
				end

				print("󰒋 LSP Status for buffer " .. bufnr .. ":")
				print(
					"─────────────────────────────────"
				)

				for i, client in ipairs(clients) do
					print(string.format("󰌘 Client %d: %s (ID: %d)", i, client.name, client.id))
					print("  Root: " .. (client.config.root_dir or "N/A"))
					print("  Filetypes: " .. table.concat(client.config.filetypes or {}, ", "))

					-- Check capabilities
					local caps = client.server_capabilities
					local features = {}
					if caps.completionProvider then
						table.insert(features, "completion")
					end
					if caps.hoverProvider then
						table.insert(features, "hover")
					end
					if caps.definitionProvider then
						table.insert(features, "definition")
					end
					if caps.referencesProvider then
						table.insert(features, "references")
					end
					if caps.renameProvider then
						table.insert(features, "rename")
					end
					if caps.codeActionProvider then
						table.insert(features, "code_action")
					end
					if caps.documentFormattingProvider then
						table.insert(features, "formatting")
					end

					print("  Features: " .. table.concat(features, ", "))
					print("")
				end
			end

			vim.api.nvim_create_user_command("LspStatus", lsp_status, { desc = "Show detailed LSP status" })

			local function check_lsp_capabilities()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				if #clients == 0 then
					print("No LSP clients attached")
					return
				end

				for _, client in ipairs(clients) do
					print("Capabilities for " .. client.name .. ":")
					local caps = client.server_capabilities

					local capability_list = {
						{ "Completion", caps.completionProvider },
						{ "Hover", caps.hoverProvider },
						{ "Signature Help", caps.signatureHelpProvider },
						{ "Go to Definition", caps.definitionProvider },
						{ "Go to Declaration", caps.declarationProvider },
						{ "Go to Implementation", caps.implementationProvider },
						{ "Go to Type Definition", caps.typeDefinitionProvider },
						{ "Find References", caps.referencesProvider },
						{ "Document Highlight", caps.documentHighlightProvider },
						{ "Document Symbol", caps.documentSymbolProvider },
						{ "Workspace Symbol", caps.workspaceSymbolProvider },
						{ "Code Action", caps.codeActionProvider },
						{ "Code Lens", caps.codeLensProvider },
						{ "Document Formatting", caps.documentFormattingProvider },
						{ "Document Range Formatting", caps.documentRangeFormattingProvider },
						{ "Rename", caps.renameProvider },
						{ "Folding Range", caps.foldingRangeProvider },
						{ "Selection Range", caps.selectionRangeProvider },
					}

					for _, cap in ipairs(capability_list) do
						local status = cap[2] and "✓" or "✗"
						print(string.format("  %s %s", status, cap[1]))
					end
					print("")
				end
			end

			vim.api.nvim_create_user_command(
				"LspCapabilities",
				check_lsp_capabilities,
				{ desc = "Show LSP capabilities" }
			)

			local function lsp_diagnostics_info()
				local bufnr = vim.api.nvim_get_current_buf()
				local diagnostics = vim.diagnostic.get(bufnr)

				local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

				for _, diagnostic in ipairs(diagnostics) do
					local severity = vim.diagnostic.severity[diagnostic.severity]
					counts[severity] = counts[severity] + 1
				end

				print("󰒡 Diagnostics for current buffer:")
				print("  Errors: " .. counts.ERROR)
				print("  Warnings: " .. counts.WARN)
				print("  Info: " .. counts.INFO)
				print("  Hints: " .. counts.HINT)
				print("  Total: " .. #diagnostics)
			end

			vim.api.nvim_create_user_command(
				"LspDiagnostics",
				lsp_diagnostics_info,
				{ desc = "Show LSP diagnostics count" }
			)

			local function lsp_info()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				print(
					"═══════════════════════════════════"
				)
				print("           LSP INFORMATION          ")
				print(
					"═══════════════════════════════════"
				)
				print("")

				-- Basic info
				print("󰈙 Language client log: " .. vim.lsp.get_log_path())
				print("󰈔 Detected filetype: " .. vim.bo.filetype)
				print("󰈮 Buffer: " .. bufnr)
				print("󰈔 Root directory: " .. (vim.fn.getcwd() or "N/A"))
				print("")

				if #clients == 0 then
					print("󰅚 No LSP clients attached to buffer " .. bufnr)
					print("")
					print("Possible reasons:")
					print("  • No language server installed for " .. vim.bo.filetype)
					print("  • Language server not configured")
					print("  • Not in a project root directory")
					print("  • File type not recognized")
					return
				end

				print("󰒋 LSP clients attached to buffer " .. bufnr .. ":")
				print(
					"─────────────────────────────────"
				)

				for i, client in ipairs(clients) do
					print(string.format("󰌘 Client %d: %s", i, client.name))
					print("  ID: " .. client.id)
					print("  Root dir: " .. (client.config.root_dir or "Not set"))
					print("  Command: " .. table.concat(client.config.cmd or {}, " "))
					print("  Filetypes: " .. table.concat(client.config.filetypes or {}, ", "))

					-- Server status
					if client.is_stopped() then
						print("  Status: 󰅚 Stopped")
					else
						print("  Status: 󰄬 Running")
					end

					-- Workspace folders
					if client.workspace_folders and #client.workspace_folders > 0 then
						print("  Workspace folders:")
						for _, folder in ipairs(client.workspace_folders) do
							print("    • " .. folder.name)
						end
					end

					-- Attached buffers count
					local attached_buffers = {}
					for buf, _ in pairs(client.attached_buffers or {}) do
						table.insert(attached_buffers, buf)
					end
					print("  Attached buffers: " .. #attached_buffers)

					-- Key capabilities
					local caps = client.server_capabilities
					local key_features = {}
					if caps.completionProvider then
						table.insert(key_features, "completion")
					end
					if caps.hoverProvider then
						table.insert(key_features, "hover")
					end
					if caps.definitionProvider then
						table.insert(key_features, "definition")
					end
					if caps.documentFormattingProvider then
						table.insert(key_features, "formatting")
					end
					if caps.codeActionProvider then
						table.insert(key_features, "code_action")
					end

					if #key_features > 0 then
						print("  Key features: " .. table.concat(key_features, ", "))
					end

					print("")
				end

				-- Diagnostics summary
				local diagnostics = vim.diagnostic.get(bufnr)
				if #diagnostics > 0 then
					print("󰒡 Diagnostics Summary:")
					local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

					for _, diagnostic in ipairs(diagnostics) do
						local severity = vim.diagnostic.severity[diagnostic.severity]
						counts[severity] = counts[severity] + 1
					end

					print("  󰅚 Errors: " .. counts.ERROR)
					print("  󰀪 Warnings: " .. counts.WARN)
					print("  󰋽 Info: " .. counts.INFO)
					print("  󰌶 Hints: " .. counts.HINT)
					print("  Total: " .. #diagnostics)
				else
					print("󰄬 No diagnostics")
				end

				print("")
				print("Use :LspLog to view detailed logs")
				print("Use :LspCapabilities for full capability list")
			end

			-- Create command
			vim.api.nvim_create_user_command("LspInfo", lsp_info, { desc = "Show comprehensive LSP information" })

			local function lsp_status_short()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })

				if #clients == 0 then
					return "" -- Return empty string when no LSP
				end

				local names = {}
				for _, client in ipairs(clients) do
					table.insert(names, client.name)
				end

				return "󰒋 " .. table.concat(names, ",")
			end

			local function git_branch()
				local ok, handle = pcall(io.popen, "git branch --show-current 2>/dev/null")
				if not ok or not handle then
					return ""
				end
				local branch = handle:read("*a")
				handle:close()
				if branch and branch ~= "" then
					branch = branch:gsub("\n", "")
					return " 󰊢 " .. branch
				end
				return ""
			end

			local function formatter_status()
				local ok, conform = pcall(require, "conform")
				if not ok then
					return ""
				end

				local formatters = conform.list_formatters_to_run(0)
				if #formatters == 0 then
					return ""
				end

				local formatter_names = {}
				for _, formatter in ipairs(formatters) do
					table.insert(formatter_names, formatter.name)
				end

				return "󰉿 " .. table.concat(formatter_names, ",")
			end

			local function linter_status()
				local ok, lint = pcall(require, "lint")
				if not ok then
					return ""
				end

				local linters = lint.linters_by_ft[vim.bo.filetype] or {}
				if #linters == 0 then
					return ""
				end

				return "󰁨 " .. table.concat(linters, ",")
			end
			-- Safe wrapper functions for statusline
			local function safe_git_branch()
				local ok, result = pcall(git_branch)
				return ok and result or ""
			end

			local function safe_lsp_status()
				local ok, result = pcall(lsp_status_short)
				return ok and result or ""
			end

			local function safe_formatter_status()
				local ok, result = pcall(formatter_status)
				return ok and result or ""
			end

			local function safe_linter_status()
				local ok, result = pcall(linter_status)
				return ok and result or ""
			end

			_G.git_branch = safe_git_branch
			_G.lsp_status = safe_lsp_status
			_G.formatter_status = safe_formatter_status
			_G.linter_status = safe_linter_status

			-- THEN set the statusline
			vim.opt.statusline = table.concat({
				"%{v:lua.git_branch()}", -- Git branch
				"%f", -- File name
				"%m", -- Modified flag
				"%r", -- Readonly flag
				"%=", -- Right align
				"%{v:lua.linter_status()}", -- Linter status
				"%{v:lua.formatter_status()}", -- Formatter status
				"%{v:lua.lsp_status()}", -- LSP status
				" %l:%c", -- Line:Column
				" %p%%", -- Percentage through file
			}, " ")
		end,
	},

	-- Поддержка CMake
	{ "cdelledonne/vim-cmake" },
}
