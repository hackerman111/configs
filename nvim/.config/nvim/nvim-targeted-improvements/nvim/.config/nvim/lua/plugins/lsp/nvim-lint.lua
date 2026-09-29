return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- Keep nvim-lint complementary to LSP. Ruff, clangd, rust-analyzer,
			-- lua_ls and texlab already produce diagnostics and are not duplicated.
			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				markdown = { "markdownlint-cli2" },
				dockerfile = { "hadolint" },
			}

			local function try_available_linters(bufnr)
				bufnr = bufnr or 0
				local names = lint.linters_by_ft[vim.bo[bufnr].filetype] or {}

				for _, name in ipairs(names) do
					local linter = lint.linters[name]
					if linter then
						local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
						if type(cmd) ~= "string" or vim.fn.executable(cmd) == 1 then
							lint.try_lint(name)
						end
					end
				end
			end

			local group = vim.api.nvim_create_augroup("user-lint-on-save", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = group,
				callback = function(args)
					if not vim.b[args.buf].auto_save_in_progress then
						try_available_linters(args.buf)
					end
				end,
			})

			vim.keymap.set("n", "<leader>gl", function()
				try_available_linters(0)
			end, { desc = "Запустить внешний линтер" })
		end,
	},
}
