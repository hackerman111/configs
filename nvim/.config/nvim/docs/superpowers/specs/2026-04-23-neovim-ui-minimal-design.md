# Neovim UI Minimal Redesign

Date: 2026-04-23

## Summary

Redesign the current Neovim UI to look professional, stylish, and minimal
without changing the established identity of the setup. The `nord` colorscheme
and the existing ASCII dashboard header remain unchanged. `alpha-nvim` and
`bufferline.nvim` stay in place. The main changes are:

- simplify the UI architecture around native Neovim 0.12.1 features,
- make `lualine.nvim` the primary status surface,
- keep `noice.nvim` only for cmdline/search/history improvements,
- stop routing Neovim errors through popup notifications,
- keep diagnostic virtual text enabled, but make it quieter and more polished.

## Goals

- Keep the current visual identity centered on `nord`.
- Make the UI feel coherent instead of mixed across multiple themes.
- Show Neovim core errors as normal editor messages, not transient notify toasts.
- Preserve inline diagnostics, but make them less noisy and more editorial.
- Use stable Neovim 0.12 features where they improve consistency.
- Minimize overlap between plugins that compete for the same UI surfaces.

## Constraints

- Keep `nord` as the active colorscheme.
- Keep the existing ASCII header in `alpha-nvim`.
- Do not change `alpha-nvim` layout or `bufferline.nvim`.
- `noice.nvim` may remain, but not as the main error notification layer.
- The result should feel minimal, not flat or unfinished.

## Non-Goals

- Replacing the dashboard.
- Replacing the tab/buffer navigation model.
- Turning off diagnostic virtual text entirely.
- Enabling every new Neovim 0.12 UI experiment just because it exists.

## Current Problems

### Theme fragmentation

The current UI is not visually unified:

- `nord` is the active colorscheme in [lua/plugins/ui/ui.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/ui/ui.lua:26).
- `incline.nvim` pulls colors from `solarized-osaka`, which creates a second
  accent system in the same interface.
- `lualine.nvim` uses only `theme = "auto"`, so the statusline does not behave
  like an intentional design surface.

### Error handling is routed like notifications

The current `noice.nvim` config sends ordinary messages and errors to `notify`
views in [lua/plugins/ui/noice.nvim.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/ui/noice.nvim.lua:23).
That conflicts with the desired behavior for Neovim core errors.

### Diagnostics are functionally correct but visually blunt

The current diagnostic setup in
[lua/plugins/lsp/lsp_and_lang.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/lsp_and_lang.lua:128)
keeps useful defaults such as `underline`, `signs`, `severity_sort`, and
rounded floats, but uses generic `virtual_text = true` with no curation.

## Design Decisions

### 1. UI Architecture

The final UI should be split into four layers:

- Native Neovim 0.12.1 for message semantics, borders, diagnostics status, and
  progress status.
- `lualine.nvim` as the main operational status surface.
- `noice.nvim` only for cmdline, search UI, and message history.
- `snacks.nvim` for modern `vim.ui.input` and `vim.ui.select`, plus shared
  float styling where useful.

The `ui2` experimental Neovim message layer will not be enabled. It overlaps
directly with `noice.nvim` and would add another competing cmdline/message
system.

### 2. Theme Cohesion

The redesign keeps `nord`, but removes conflicting accent logic from the rest
of the UI:

- any `solarized-osaka`-driven highlight styling should be removed from the
  active interface,
- floating windows, statusline sections, and diagnostic accents should all read
  as part of the same cold, low-saturation `nord` palette,
- borders should be visible but understated.

### 3. Neovim 0.12 Features To Use

The redesign should explicitly use:

- `vim.diagnostic.status()` in the statusline,
- `vim.ui.progress_status()` in the statusline,
- `vim.o.winborder` for consistent floating window borders,
- `vim.o.pumborder` for completion/documentation popup borders,
- `vim.o.messagesopt` for a cleaner message flow with normal editor semantics.

## Component Design

### Lualine

`lualine.nvim` becomes the main place where state is summarized. It should be
clean, information-dense, and calm.

#### Visual rules

- Use an explicit `nord`-compatible theme instead of `theme = "auto"`.
- Prefer flat sections or very light separators.
- Avoid decorative noise and duplicate status signals.
- Inactive windows should show only a minimal file/location summary.

#### Active sections

- `lualine_a`: current mode, short and readable.
- `lualine_b`: git branch and diff.
- `lualine_c`: file path and file state (`modified`, `readonly`, unnamed file).
- `lualine_x`: diagnostics summary from `vim.diagnostic.status()` and active
  background work from `vim.ui.progress_status()`.
- `lualine_y`: active LSP clients for the current buffer and optional formatter
  context when available.
- `lualine_z`: line, column, and progress through file.

#### Inactive windows

- Show only filename/path plus cursor position.
- Reduce contrast so the active window keeps focus.

#### Special buffers

Hide or simplify the statusline for dedicated utility buffers such as:

- `alpha`,
- `lazy`,
- `mason`,
- `help`,
- `oil`,
- `trouble`,
- transient picker-like buffers.

### Noice

`noice.nvim` remains installed, but its role narrows.

#### Keep

- cmdline presentation,
- search UI,
- message history and redirection,
- optional LSP hover/signature integration only if it does not reintroduce
  popup-style error behavior.

#### Remove from its role

- notify-style rendering for ordinary errors and warnings,
- notify-style rendering for Neovim core command failures,
- routing that makes core editor errors feel like toast notifications.

Neovim errors such as `E...`, `W...`, Lua tracebacks, and command execution
failures should appear as ordinary Neovim messages in the command/message area
and remain accessible through `:messages`.

### Snacks

`snacks.nvim` should replace `dressing.nvim` as the active `vim.ui.*` helper.

- Use `snacks` for `vim.ui.input`.
- Use `snacks` for `vim.ui.select`.
- Reuse shared `snacks` styles when that helps floating windows feel coherent.

`dressing.nvim` is archived upstream and should not stay in the active UI path.

## Diagnostics Design

Diagnostics remain visible in four places:

- sign column,
- underline,
- inline virtual text,
- float/list views.

The interface should not depend on notifications for diagnostics.

### Signs

Keep severity-aware sign icons and keep `severity_sort = true`.

Signs remain the fastest low-noise scan signal in the gutter.

### Underline

Keep underlines enabled.

They should remain severity-aware and avoid replacing the role of signs or
virtual text.

### Virtual Text

Virtual text stays enabled, but becomes quieter and more intentional.

Recommended behavior:

- `spacing = 2`,
- `source = "if_many"`,
- `current_line = false`,
- custom `prefix` function with a subtle marker,
- custom `format` function that shortens noisy messages and trims punctuation,
- only `ERROR` and `WARN` in virtual text by default.

Professional visual target:

- first diagnostic on a line uses a light marker such as `●`,
- additional diagnostics use a lighter continuation marker such as `·`,
- text reads like margin annotation, not like log spam,
- `INFO` and `HINT` remain available in float, `Trouble`, and statusline
  summaries instead of filling the code column.

### Diagnostic Float

The diagnostic float becomes the main detail surface.

- Keep rounded borders or a shared global border via `winborder`.
- Keep source display, preferably `source = "if_many"` or `true` when needed.
- Use a compact prefix and readable formatting.
- Open by explicit mapping or hover behavior, not as a notification.

### Aggregated Views

`Trouble` or location list remains the right place for overview and navigation.

The statusline should complement those views through `vim.diagnostic.status()`,
not replace them.

## Error And Message Behavior

This distinction is required:

- Neovim core errors are ordinary editor messages.
- Diagnostics are editor annotations tied to code.
- Transient notifications are optional UX sugar and should not become the main
  transport for actual failures.

Therefore:

- core Neovim errors do not render as `notify` popups,
- `:messages` remains authoritative for message history,
- statusline reflects counts and progress,
- diagnostics remain in-buffer, not in toasts.

## Files Expected To Change During Implementation

- [lua/config/options.lua](/home/papayka/configs/nvim/.config/nvim/lua/config/options.lua:1)
  for Neovim 0.12 global UI options like `winborder`, `pumborder`, and
  `messagesopt`.
- [lua/plugins/ui/ui.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/ui/ui.lua:1)
  for the `lualine.nvim` redesign and any `snacks.nvim` UI wiring.
- [lua/plugins/ui/noice.nvim.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/ui/noice.nvim.lua:1)
  to limit `noice.nvim` to cmdline/search/history and stop notify-style error
  routing.
- [lua/plugins/lsp/lsp_and_lang.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/lsp_and_lang.lua:1)
  for professional diagnostic formatting and virtual text behavior.
- [lua/plugins/ui/dressing.nvim.lua](/home/papayka/configs/nvim/.config/nvim/lua/plugins/ui/dressing.nvim.lua:1)
  to remove or disable archived `dressing.nvim` from the active UI path.

## Verification Plan

Implementation should be considered complete only after checking:

1. `nvim --headless "+Lazy! sync" +qa` or an equivalent minimal startup check
   succeeds without new config errors.
2. Opening Neovim and triggering a known core error shows a normal Neovim
   message, not a popup notification.
3. Lualine shows diagnostics and progress using Neovim 0.12 core functions.
4. Virtual text remains enabled, but only shows curated inline messaging.
5. Hover, signature help, and picker/input borders look visually consistent.

## Acceptance Criteria

- `nord`, the ASCII dashboard header, `alpha-nvim`, and `bufferline.nvim`
  remain intact.
- `lualine.nvim` becomes more detailed and visibly intentional.
- Neovim core errors no longer appear as notify-style popups.
- Virtual text remains enabled and looks restrained rather than noisy.
- The UI feels coherent and minimal instead of theme-mixed.
