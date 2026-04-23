# Neovim Completion Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `blink.cmp` as the default completion engine with a richer UI and more useful sources, while adding `coq.nvim` in a separate plugin file as a clean alternative completion engine.

**Architecture:** Introduce a tiny completion helper that owns engine selection and LSP capability wrapping, then wire both `blink` and `coq` through that helper. Upgrade `blink` in place, add `coq.lua` as a standalone spec, and cover the shared behavior with one focused headless test file.

**Tech Stack:** Neovim 0.12.x, Lua, lazy.nvim, saghen/blink.cmp, ms-jpq/coq_nvim, ms-jpq/coq.artifacts, ms-jpq/coq.thirdparty, Copilot, headless `nvim`

---

## File Map

- Create: `lua/config/completion.lua`
- Create: `lua/plugins/lsp/coq.lua`
- Create: `tests/completion_stack_spec.lua`
- Modify: `lua/plugins/lsp/blink.lua`
- Modify: `lua/plugins/lsp/lsp_and_lang.lua`
- Modify: `docs/superpowers/specs/2026-04-23-neovim-completion-stack-design.md` only if implementation reveals a design mismatch

### Task 1: Add a Shared Completion Helper

**Files:**
- Create: `lua/config/completion.lua`
- Test: `tests/completion_stack_spec.lua`

- [ ] **Step 1: Write the failing helper test**

```lua
local completion = require("config.completion")

assert(completion.get_engine() == "blink", "default engine should be blink")
assert(completion.is_blink() == true, "blink predicate should be true by default")
assert(completion.is_coq() == false, "coq predicate should be false by default")

local caps = { textDocument = { completion = { completionItem = { snippetSupport = false } } } }
assert(completion.get_lsp_capabilities(caps) == caps, "helper should return original capabilities when backend is unavailable")
```

- [ ] **Step 2: Run the helper test to verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: FAIL with `module 'config.completion' not found`.

- [ ] **Step 3: Write the minimal helper implementation**

```lua
local M = {}

function M.get_engine()
  local engine = vim.g.completion_engine
  if engine == "coq" then
    return "coq"
  end
  return "blink"
end

function M.is_blink()
  return M.get_engine() == "blink"
end

function M.is_coq()
  return M.get_engine() == "coq"
end

function M.get_lsp_capabilities(capabilities)
  if M.is_blink() then
    local ok, blink = pcall(require, "blink.cmp")
    if ok and type(blink.get_lsp_capabilities) == "function" then
      return blink.get_lsp_capabilities(capabilities)
    end
  end

  if M.is_coq() then
    local ok, coq = pcall(require, "coq")
    if ok and type(coq.lsp_ensure_capabilities) == "function" then
      return coq.lsp_ensure_capabilities(capabilities)
    end
  end

  return capabilities
end

return M
```

- [ ] **Step 4: Run the helper test to verify it passes**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: PASS with `completion_stack_spec: ok`.

### Task 2: Add `coq` as a Separate Completion Engine

**Files:**
- Create: `lua/plugins/lsp/coq.lua`
- Test: `tests/completion_stack_spec.lua`

- [ ] **Step 1: Extend the failing test for `coq` spec shape**

```lua
local coq_spec = dofile(cwd .. "/lua/plugins/lsp/coq.lua")
assert(type(coq_spec) == "table", "coq spec should return a plugin list")
assert(coq_spec[1][1] == "ms-jpq/coq_nvim", "first coq plugin should be coq_nvim")
assert(type(coq_spec[1].init) == "function", "coq init should exist")
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: FAIL with `cannot open lua/plugins/lsp/coq.lua`.

- [ ] **Step 3: Write the `coq` plugin spec**

```lua
local completion = require("config.completion")

return {
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    enabled = function()
      return completion.is_coq()
    end,
    dependencies = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
      { "ms-jpq/coq.thirdparty", branch = "3p" },
      { "zbirenbaum/copilot.lua" },
    },
    init = function()
      vim.g.coq_settings = {
        auto_start = "shut-up",
      }
    end,
    config = function()
      require("coq_3p")({
        { src = "copilot", short_name = "COP", accept_key = "<C-f>" },
        { src = "nvimlua", short_name = "nLUA" },
        { src = "vimtex", short_name = "vTEX" },
      })
    end,
  },
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: PASS with no `coq.lua` load errors.

### Task 3: Upgrade `blink` Without Enabling Snippets

**Files:**
- Modify: `lua/plugins/lsp/blink.lua`
- Test: `tests/completion_stack_spec.lua`

- [ ] **Step 1: Extend the failing test for `blink` behavior**

```lua
local blink_spec = dofile(cwd .. "/lua/plugins/lsp/blink.lua")
local blink_opts = {}
blink_spec[2].opts(nil, blink_opts)

assert(blink_opts.snippets == nil or blink_opts.snippets.preset ~= "luasnip", "blink snippets must stay disabled")
assert(blink_opts.sources.default ~= nil, "blink sources should be configured")
assert(blink_opts.signature.enabled == true, "blink signature help should be enabled")
assert(blink_opts.cmdline.enabled == true, "blink cmdline should stay enabled")
assert(type(blink_opts.completion.menu.draw.columns) == "table", "blink menu columns should be customized")
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: FAIL because `blink` still enables the `luasnip` preset and lacks the new structured menu assertions.

- [ ] **Step 3: Implement the `blink` redesign**

```lua
opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
  default = { "lsp", "path", "buffer", "copilot", "emoji", "dictionary", "ripgrep" },
})

opts.signature = { enabled = true, window = { border = vim.o.winborder } }
opts.cmdline = {
  enabled = true,
  keymap = { preset = "inherit" },
  completion = {
    menu = {
      auto_show = function()
        return vim.fn.getcmdtype() == ":"
      end,
    },
  },
}

opts.completion.menu.draw = {
  columns = {
    { "item_idx" },
    { "kind_icon" },
    { "label", "label_description", gap = 1 },
    { "source_name" },
  },
}
```

- [ ] **Step 4: Add `BlinkCmpMenuOpen` / `BlinkCmpMenuClose` Copilot coexistence autocmds**

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    require("copilot.suggestion").dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuClose",
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})
```

- [ ] **Step 5: Run the test to verify it passes**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: PASS with `blink` snippet assertions and menu assertions satisfied.

### Task 4: Make LSP Capabilities Backend-Agnostic

**Files:**
- Modify: `lua/plugins/lsp/lsp_and_lang.lua`
- Test: `tests/completion_stack_spec.lua`

- [ ] **Step 1: Extend the failing test for helper-based capability wiring**

```lua
local lsp_file = table.concat(vim.fn.readfile(cwd .. "/lua/plugins/lsp/lsp_and_lang.lua"), "\n")
assert(lsp_file:find('require%("config%.completion"%)') ~= nil, "lsp_and_lang should depend on shared completion helper")
assert(lsp_file:find('require%("blink%.cmp"%)%.get_lsp_capabilities') == nil, "lsp_and_lang should not hardcode blink capabilities")
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: FAIL because `lsp_and_lang.lua` still hardcodes `blink.cmp`.

- [ ] **Step 3: Refactor the LSP setup**

```lua
local completion = require("config.completion")

for server, server_opts in pairs(opts.servers) do
  server_opts.capabilities = completion.get_lsp_capabilities(server_opts.capabilities)
  vim.lsp.config(server, server_opts)
  vim.lsp.enable(server)
end
```

- [ ] **Step 4: Run the headless test to verify it passes**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: PASS with `completion_stack_spec: ok`.

### Task 5: Run Final Verification

**Files:**
- Verify: `lua/config/completion.lua`
- Verify: `lua/plugins/lsp/blink.lua`
- Verify: `lua/plugins/lsp/coq.lua`
- Verify: `lua/plugins/lsp/lsp_and_lang.lua`
- Verify: `tests/completion_stack_spec.lua`

- [ ] **Step 1: Run the focused headless regression test**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/completion_stack_spec.lua").run()' +qa
```

Expected: PASS with `completion_stack_spec: ok`.

- [ ] **Step 2: Run full config smoke startup**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim --headless "+qa"
```

Expected: exit code `0`.

- [ ] **Step 3: Run diff hygiene**

Run:

```bash
git diff --check -- lua/config/completion.lua lua/plugins/lsp/blink.lua lua/plugins/lsp/coq.lua lua/plugins/lsp/lsp_and_lang.lua tests/completion_stack_spec.lua
```

Expected: no whitespace or conflict-marker errors.
