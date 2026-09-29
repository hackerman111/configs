return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			local function format_on_save(bufnr)
				if vim.b[bufnr].disable_autoformat or vim.b[bufnr].auto_save_in_progress then
					return nil
				end
				if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
					return nil
				end

				return {
					timeout_ms = 1000,
					lsp_format = "fallback",
				}
			end

			conform.setup({
				formatters_by_ft = {
					markdown = { "prettier" },
					lua = { "stylua" },
					-- ruff_fix applies safe fixes by default, then Ruff formats.
					-- This replaces the old isort + generic `ruff` formatter chain.
					python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
					c = { "clang_format" },
					cpp = { "clang_format" },
					rust = { "rustfmt" },
				},
				format_on_save = format_on_save,
			})

			vim.keymap.set({ "n", "v" }, "<leader>gf", function()
				conform.format({ async = true, lsp_format = "fallback" })
			end, { desc = "Форматировать" })

			vim.api.nvim_create_user_command("FormatToggle", function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("format-on-save: " .. (vim.b.disable_autoformat and "off" or "on"))
			end, { desc = "Переключить format-on-save для текущего буфера" })
		end,
	},
}
