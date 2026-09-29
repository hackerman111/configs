# Targeted Neovim improvements

This bundle mirrors paths under `nvim/.config/nvim/` from `hackerman111/configs`.
It is intentionally small: completion, formatting/linting/code actions, DAP Python support, and Neotest Python support.

## Files

- `lua/plugins/lsp/blink.lua`: stable Blink v1, explicit selection, smaller semantic source set, sane ranking.
- `lua/plugins/lsp/conform.lua`: current Conform API, Ruff safe fixes + import organization + formatting, skips autosave writes.
- `lua/plugins/lsp/nvim-lint.lua`: save-only complementary linters; does not duplicate Ruff/clangd/rust-analyzer.
- `lua/config/lsp.lua`: preserves current LSP setup and adds direct quick-fix/Ruff fix-all/import actions.
- `lua/plugins/editor/auto-save_nvim.lua`: moves plugin options into `opts` and tags autosave writes instead of suppressing all write autocmds.
- `lua/config/python.lua`: one project-Python resolver shared by DAP and tests.
- `lua/plugins/debug/debug.lua`: keeps nvim-dap-ui, fixes C/C++ executable resolution, adds debugpy via Mason and ML-oriented Python launch/attach profiles.
- `lua/plugins/debug/neotest.lua`: minimal pytest/unittest test workflow; debug-nearest through DAP.

## After copying

Run `:Lazy sync`, then `:Mason` once and confirm `debugpy`/`codelldb` are installed. Blink dependencies removed from the spec can be removed with `:Lazy clean` after review.

External optional linters used by `nvim-lint.lua` are `shellcheck`, `markdownlint-cli2`, and `hadolint`. Missing executables are skipped silently.

## Main mappings added/changed

- Blink: `<C-n>/<C-p>` select, `<C-y>` accept, `<C-e>` cancel, `<C-Space>` menu/docs. Enter and Tab are not captured by Blink.
- Code actions: `<leader>cf` quick fix, `<leader>cF` Ruff safe fix-all, `<leader>ci` Ruff organize imports.
- Formatting: `<leader>gf`; `:FormatToggle` toggles format-on-save for the current buffer.
- Tests: `<leader>Tr` nearest, `Tf` file, `Ta` project, `Tl` rerun, `Td` debug nearest, `Ts` summary, `To` output, `Tx` stop, `Tw` watch file.
- DAP keeps the existing `<leader>d...` family and adds Python profiles.
