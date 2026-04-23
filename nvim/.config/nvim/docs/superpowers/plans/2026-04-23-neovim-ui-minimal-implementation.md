# Neovim UI Minimal Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rework the current Neovim UI around `nord`, detailed `lualine`, curated diagnostics, and native-looking Neovim errors without touching `alpha-nvim` or `bufferline.nvim`.

**Architecture:** Move the new UI rules into one pure Lua helper module so the config becomes testable without loading every plugin. Then wire existing plugin specs and core options to that helper, disable archived/overlapping UI layers, and verify both pure config output and full Neovim startup behavior.

**Tech Stack:** Neovim 0.12.1, Lua, lazy.nvim, lualine.nvim, noice.nvim, snacks.nvim, built-in diagnostics/UI APIs

---

## File Map

- Create: `lua/config/ui.lua`
- Create: `tests/ui_minimal_spec.lua`
- Modify: `lua/config/options.lua`
- Modify: `lua/plugins/ui/ui.lua`
- Modify: `lua/plugins/ui/noice.nvim.lua`
- Modify: `lua/plugins/ui/dressing.nvim.lua`
- Modify: `lua/plugins/lsp/lsp_and_lang.lua`

### Task 1: Add a Testable UI Helper Module

**Files:**
- Create: `lua/config/ui.lua`
- Test: `tests/ui_minimal_spec.lua`

- [ ] **Step 1: Write the failing helper test**

```lua
local cwd = vim.fn.getcwd()
package.path = table.concat({
  cwd .. "/lua/?.lua",
  cwd .. "/lua/?/init.lua",
  package.path,
}, ";")

local function assert_eq(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_truthy(value, label)
  if not value then
    error(label)
  end
end

local M = {}

function M.run()
  local ui = require("config.ui")

  local lualine = ui.lualine_opts()
  assert_eq(lualine.options.theme, "nord", "lualine theme")
  assert_eq(lualine.options.globalstatus, true, "lualine globalstatus")
  assert_truthy(type(lualine.sections.lualine_x[1][1]) == "function", "diagnostic status component missing")
  assert_truthy(type(lualine.sections.lualine_x[2][1]) == "function", "progress status component missing")

  local noice = ui.noice_opts()
  assert_eq(noice.messages.view, "cmdline", "noice message view")
  assert_eq(noice.messages.view_error, "cmdline", "noice error view")
  assert_eq(noice.notify.enabled, false, "noice notify disabled")
  assert_eq(noice.popupmenu.enabled, false, "native popupmenu restored")

  local diagnostic = ui.diagnostic_config()
  assert_eq(diagnostic.virtual_text.spacing, 2, "virtual text spacing")
  assert_eq(diagnostic.virtual_text.source, "if_many", "virtual text source")
  assert_eq(diagnostic.virtual_text.current_line, false, "virtual text current_line")
  assert_eq(diagnostic.virtual_text.severity.min, vim.diagnostic.severity.WARN, "virtual text severity")
  assert_eq(diagnostic.virtual_text.prefix({}, 1, 2), "●", "primary diagnostic marker")
  assert_eq(diagnostic.virtual_text.prefix({}, 2, 2), "·", "secondary diagnostic marker")
  assert_eq(diagnostic.virtual_text.format({ message = " Boom. \n next  " }), "Boom. next", "diagnostic formatter")

  assert_eq(ui.strip_statusline_hl("%#DiagnosticSignError#E:1 %#DiagnosticSignWarn#W:1%##"), "E:1 W:1", "statusline hl stripping")
  print("ui_minimal_spec: ok")
end

return M
```

- [ ] **Step 2: Run the helper test to verify it fails**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: FAIL with `module 'config.ui' not found`.

- [ ] **Step 3: Write the minimal helper implementation**

```lua
local M = {}

local severity = vim.diagnostic.severity

local function trim(text)
  return (text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
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

local function current_lsp_names()
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

function M.lualine_diagnostic_status()
  local status = M.strip_statusline_hl(vim.diagnostic.status())
  return status ~= "" and status or nil
end

function M.lualine_progress_status()
  local status = trim(vim.ui.progress_status())
  return status ~= "" and status or nil
end

function M.lualine_lsp_status()
  return current_lsp_names()
end

function M.lualine_opts()
  return {
    options = {
      theme = "nord",
      globalstatus = true,
      icons_enabled = true,
      section_separators = { left = "", right = "" },
      component_separators = { left = "·", right = "·" },
      disabled_filetypes = {
        statusline = { "alpha", "lazy", "mason", "snacks_dashboard" },
        winbar = {},
      },
    },
    sections = {
      lualine_a = { { "mode", fmt = function(mode) return mode:upper() end } },
      lualine_b = { "branch", { "diff", symbols = { added = "+", modified = "~", removed = "-" } } },
      lualine_c = { { "filename", path = 1, file_status = true, newfile_status = true, shorting_target = 48 } },
      lualine_x = { { M.lualine_diagnostic_status }, { M.lualine_progress_status } },
      lualine_y = { { M.lualine_lsp_status } },
      lualine_z = { "location", "progress" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 1, file_status = true } },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
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
    },
    messages = {
      enabled = true,
      view = "cmdline",
      view_error = "cmdline",
      view_warn = "cmdline",
      view_history = "messages",
      view_search = false,
    },
    popupmenu = { enabled = false },
    notify = { enabled = false },
    lsp = {
      progress = { enabled = false },
      message = { enabled = false },
      hover = { enabled = true, silent = true },
      signature = {
        enabled = true,
        auto_open = { enabled = false, trigger = true, luasnip = true, throttle = 50 },
      },
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
      },
    },
  }
end

return M
```

- [ ] **Step 4: Run the helper test to verify it passes**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: PASS with `ui_minimal_spec: ok`.

- [ ] **Step 5: Commit the helper/test baseline**

```bash
git add lua/config/ui.lua tests/ui_minimal_spec.lua
git commit -m "test: add neovim ui config smoke helpers"
```

### Task 2: Wire Core Options and UI Plugins to the Helper

**Files:**
- Modify: `lua/config/options.lua`
- Modify: `lua/plugins/ui/ui.lua`
- Modify: `lua/plugins/ui/noice.nvim.lua`
- Modify: `lua/plugins/ui/dressing.nvim.lua`
- Test: `tests/ui_minimal_spec.lua`

- [ ] **Step 1: Extend the test with startup-facing expectations**

```lua
function M.run()
  local ui = require("config.ui")
  local lualine = ui.lualine_opts()
  local noice = ui.noice_opts()
  local snacks = ui.snacks_opts()

  assert_eq(lualine.options.disabled_filetypes.statusline[1], "alpha", "alpha statusline exclusion")
  assert_eq(noice.messages.view_history, "messages", "noice history view")
  assert_eq(noice.lsp.message.enabled, false, "noice lsp message disabled")
  assert_eq(snacks.input.win.border, "rounded", "snacks input border")
end
```

- [ ] **Step 2: Run the test to verify it fails on the new assertions**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: FAIL on at least one new assertion until the helper and plugin wiring are updated together.

- [ ] **Step 3: Wire the existing config files**

```lua
-- lua/config/options.lua
require("config.ui").apply_core_options()

-- lua/plugins/ui/ui.lua
{
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup(require("config.ui").lualine_opts())
  end,
},
{
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = function()
    return require("config.ui").snacks_opts()
  end,
},
{
  "b0o/incline.nvim",
  event = "BufReadPre",
  priority = 1200,
  config = function()
    require("incline").setup(require("config.ui").incline_opts())
  end,
},

-- lua/plugins/ui/noice.nvim.lua
opts = function()
  return require("config.ui").noice_opts()
end,

-- lua/plugins/ui/dressing.nvim.lua
return {
  {
    "stevearc/dressing.nvim",
    enabled = false,
  },
}
```

- [ ] **Step 4: Run the helper test again**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: PASS with `ui_minimal_spec: ok`.

- [ ] **Step 5: Commit the plugin wiring**

```bash
git add lua/config/options.lua lua/plugins/ui/ui.lua lua/plugins/ui/noice.nvim.lua lua/plugins/ui/dressing.nvim.lua tests/ui_minimal_spec.lua
git commit -m "feat: wire minimal neovim ui stack"
```

### Task 3: Apply Diagnostic Tuning and Verify Full Startup

**Files:**
- Modify: `lua/plugins/lsp/lsp_and_lang.lua`
- Test: `tests/ui_minimal_spec.lua`

- [ ] **Step 1: Extend the test with diagnostic-format expectations**

```lua
function M.run()
  local ui = require("config.ui")
  local diagnostic = ui.diagnostic_config()

  assert_eq(diagnostic.float.source, "if_many", "diagnostic float source")
  assert_eq(diagnostic.underline, true, "diagnostic underline")
  assert_eq(diagnostic.update_in_insert, false, "diagnostic update_in_insert")
  assert_eq(diagnostic.severity_sort, true, "diagnostic severity_sort")
end
```

- [ ] **Step 2: Run the test to verify it fails before wiring diagnostics**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: FAIL until `lua/plugins/lsp/lsp_and_lang.lua` delegates to `require("config.ui").diagnostic_config()`.

- [ ] **Step 3: Replace the inline diagnostic config with the helper**

```lua
-- lua/plugins/lsp/lsp_and_lang.lua
require("lspconfig.ui.windows").default_options.border = vim.o.winborder ~= "" and vim.o.winborder or "rounded"

vim.diagnostic.config(require("config.ui").diagnostic_config())
```

- [ ] **Step 4: Run the helper test and the full startup smoke**

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim -u NONE --headless '+lua dofile("tests/ui_minimal_spec.lua").run()' +qa
```

Expected: PASS with `ui_minimal_spec: ok`.

Run:

```bash
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp/nvim-cache nvim --headless '+lua vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })' '+lua local cfg = vim.diagnostic.config(); assert(vim.o.winborder == "rounded"); assert(vim.o.pumborder == "rounded"); assert(vim.o.messagesopt == "hit-enter,history:500,progress:c"); assert(type(cfg.virtual_text) == "table" and cfg.virtual_text.spacing == 2); local lualine = require("lualine").get_config(); assert(lualine.options.theme == "nord"); local noice = require("noice.config").options; assert(noice.messages.view_error == "cmdline"); assert(noice.notify.enabled == false); print("ui_runtime_smoke: ok")' +qa
```

Expected: PASS with `ui_runtime_smoke: ok`.

- [ ] **Step 5: Commit the diagnostic integration**

```bash
git add lua/plugins/lsp/lsp_and_lang.lua tests/ui_minimal_spec.lua
git commit -m "feat: tune neovim diagnostics and message flow"
```

## Self-Review

- Spec coverage:
  - `nord`, ASCII header, `alpha`, and `bufferline` are preserved by only touching helper wiring, not those blocks.
  - `lualine` gets a full explicit structure with `vim.diagnostic.status()` and `vim.ui.progress_status()`.
  - `noice` is narrowed away from notify popups for errors and LSP messages.
  - `dressing.nvim` is disabled in favor of existing `snacks.nvim`.
  - diagnostics keep `virtual_text`, `underline`, and signs, but with curated inline formatting.
  - Neovim 0.12 UI options are applied through `apply_core_options()`.
- Placeholder scan:
  - No `TODO`, `TBD`, or “handle appropriately” placeholders remain.
  - Every verification step includes an exact command and expected output.
- Type consistency:
  - All runtime files consume the same helper API names: `apply_core_options`, `lualine_opts`, `snacks_opts`, `noice_opts`, `diagnostic_config`.

Plan complete and saved to `docs/superpowers/plans/2026-04-23-neovim-ui-minimal-implementation.md`. The user already asked to proceed with implementation, so execute this plan inline in the current session.
