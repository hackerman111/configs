return {
    "mfussenegger/nvim-lint",
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        local lint = require("lint")
        local lint_config = require("config.lint")

        lint.linters_by_ft = {
            python = { "ruff" },
            cpp = { "clangtidy" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function(args)
                if not lint_config.should_lint(args.event, args.buf) then
                    return
                end

                lint_config.try_lint(lint, args.buf)
            end,
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = lint_augroup,
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == "ruff" then
                    lint_config.clear_conflicting_diagnostics(lint, args.buf)
                end
            end,
        })

        vim.keymap.set("n", "<leader>gl", function()
            lint_config.try_lint(lint)
        end, { desc = "Линтинг" })
    end,
}
