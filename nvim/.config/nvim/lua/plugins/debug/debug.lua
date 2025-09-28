-- Assuming you use lazy.nvim for plugin management
-- Place this in your plugins file or init.lua

return {
	{ "mfussenegger/nvim-dap" },
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	{ "williamboman/mason.nvim", opts = { ensure_installed = { "codelldb" } } },
	{ "mrcjkb/rustaceanvim", version = "^5", lazy = false, ft = "rust" }, -- Опционально для Rust
}
