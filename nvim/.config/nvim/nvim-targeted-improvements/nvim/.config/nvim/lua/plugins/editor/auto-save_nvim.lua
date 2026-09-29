return {
	{
		"okuuva/auto-save.nvim",
		version = "^1.0.0",
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
		opts = {
			-- Preserve the current autosave behaviour. We only tag autosave writes
			-- so formatters/linters can skip them without suppressing every
			-- BufWrite autocmd (LSP didSave, session plugins, etc.).
			trigger_events = {
				immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
				defer_save = { "InsertLeave", "TextChanged" },
				cancel_deferred_save = { "InsertEnter" },
			},
			condition = function(buf)
				return vim.bo[buf].buftype == "" and vim.bo[buf].modifiable and vim.api.nvim_buf_get_name(buf) ~= ""
			end,
			write_all_buffers = false,
			noautocmd = false,
			debounce_delay = 1000,
		},
		config = function(_, opts)
			require("auto-save").setup(opts)

			local group = vim.api.nvim_create_augroup("user-autosave-state", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "AutoSaveWritePre",
				callback = function(event)
					local buf = event.data and event.data.saved_buffer
					if buf and vim.api.nvim_buf_is_valid(buf) then
						vim.b[buf].auto_save_in_progress = true
					end
				end,
			})
			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "AutoSaveWritePost",
				callback = function(event)
					local buf = event.data and event.data.saved_buffer
					if buf and vim.api.nvim_buf_is_valid(buf) then
						vim.b[buf].auto_save_in_progress = false
					end
				end,
			})
		end,
	},
}
