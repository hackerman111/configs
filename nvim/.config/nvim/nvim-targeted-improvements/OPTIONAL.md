# Optional additions kept out of the base patch

## Use one Python type checker

The current config starts both `ty` and `pyrefly`. If you are not comparing their diagnostics, the smallest change is to keep `ty` (it already owns completion) and remove `pyrefly` from both lists:

`lua/config/lsp.lua`
```lua
local servers = {
  "lua_ls",
  "ty",
  -- "pyrefly",
  "ruff",
  -- ...
}
```

`lua/plugins/lsp/nvim-lsp-config.lua`
```lua
ensure_installed = {
  "ty",
  -- "pyrefly",
  "lua_ls",
  "ruff",
  -- ...
}
```

If you prefer Pyrefly diagnostics/completion, do the inverse and remove `ty`, then delete the special Pyrefly completion-disable block.

## Rust tests

Only add this if you actually use Rust tests and have `cargo-nextest` installed:

```lua
-- dependency
"rouge8/neotest-rust",

-- adapter
require("neotest-rust")({ dap_adapter = "codelldb" }),
```

## C++ tests

For GoogleTest projects add `alfaix/neotest-gtest`. For CTest projects add `orjangj/neotest-ctest`. Pick the one matching the project instead of installing both globally.

## JavaScript/TypeScript tests

Add only the adapter used by the project:

```lua
"nvim-neotest/neotest-jest"
-- or
"marilari88/neotest-vitest"
```

and the matching adapter in `neotest.setup()`.

## DAP UI alternative

`igorlfs/nvim-dap-view` is a compact alternative to `nvim-dap-ui`. Do not install both. The base patch keeps your existing `nvim-dap-ui` to avoid UI churn.
