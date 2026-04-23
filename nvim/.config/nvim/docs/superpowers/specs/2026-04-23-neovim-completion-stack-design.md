# Neovim Completion Stack Redesign

Date: 2026-04-23

## Summary

Rework the completion stack so `blink.cmp` remains in the config and becomes
more polished, visually richer, and more functional, while `coq.nvim` is
introduced as a separate completion engine in its own plugin-spec file.

The result should support two clean operating modes:

- `blink` as the default completion engine with upgraded UI and sources,
- `coq` as a fully configured alternative that can replace `blink` without
  rewriting the rest of the LSP setup.

`blink` snippets are explicitly out of scope for this redesign and must remain
disabled.

## Goals

- Keep `blink.cmp` in the repo and improve its appearance and capabilities.
- Move `coq.nvim` into its own dedicated file under `lua/plugins/lsp/`.
- Preserve `Copilot` support in both completion modes.
- Avoid hard-coding LSP capabilities to `blink` so `coq` can take over cleanly.
- Keep the config coherent with the current `nord`-leaning UI choices.
- Avoid requiring manual rewrites later just to switch between engines.

## Constraints

- Do not delete the existing `blink` plugin spec.
- Do not enable snippet completion inside `blink`.
- `coq` must live in a separate file instead of commented fragments inside
  `lsp_and_lang.lua`.
- The final setup must not run `blink` and `coq` as competing insert-mode
  completion engines at the same time.
- Existing `copilot.lua` integration should remain available.

## Non-Goals

- Reproducing `blink` and `coq` as exact feature-for-feature twins.
- Enabling undocumented `coq` cmdline behavior.
- Keeping all current `blink` defaults if they make the UI noisier or less
  intentional.
- Enabling `blink` snippets.

## Current Problems

### 1. `blink` is useful but visually under-developed

The current [`blink.lua`](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/blink.lua)
already enables several providers and custom icons, but it still behaves more
like a lightly modified upstream config than an intentional completion surface.

Current gaps:

- menu layout is functional but not especially dense or elegant,
- source presentation is not strongly differentiated,
- cmdline behavior is only minimally configured,
- signature/documentation behavior is present but not tuned as a full UI layer,
- some potentially useful sources are commented out rather than clearly curated.

### 2. `coq` exists only as dead commented configuration

The current
[`lsp_and_lang.lua`](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/lsp_and_lang.lua)
contains old commented `coq_nvim` fragments, but there is no real standalone
plugin spec, no clean activation model, and no safe path for using `coq`
instead of `blink`.

### 3. LSP capability wrapping is hard-wired to `blink`

The current LSP setup calls `require("blink.cmp").get_lsp_capabilities(...)`
directly. That makes `blink` the only viable completion backend unless the user
manually rewrites the LSP bootstrap again.

## Design Decisions

### 1. Split completion responsibilities explicitly

The redesign uses a clear split:

- [`lua/plugins/lsp/blink.lua`](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/blink.lua)
  remains the home of the `blink` stack and becomes the polished default.
- Create
  [`lua/plugins/lsp/coq.lua`](/home/papayka/configs/nvim/.config/nvim/lua/plugins/lsp/coq.lua)
  for the full `coq.nvim` stack.
- Introduce one tiny shared completion helper module so the rest of the LSP
  config can ask “which engine is active?” instead of assuming `blink`.

This keeps the plugin specs isolated, makes switching engines predictable, and
removes completion-specific branching from unrelated code.

### 2. Only one insert-mode engine should be active at a time

`blink` and `coq` both want control over insert-mode completion, popup menu
behavior, previews, and completion-specific keymaps. Running both as equal
peers would create conflicting behavior.

The design therefore introduces a single engine selector, defaulting to
`"blink"`. The selector should determine:

- which plugin spec is enabled,
- which capability wrapper is used by LSP,
- which completion-specific keymaps and autocmds are active.

This keeps runtime behavior deterministic.

### 3. `blink` should be intentionally styled, not merely enabled

The upgraded `blink` configuration should emphasize density, readability, and
clear visual hierarchy.

#### `blink` visual direction

- rounded or single bordered windows that match the rest of the UI,
- a structured menu layout with index, icon, label, detail, and source,
- stronger differentiation between label text and metadata,
- explicit highlight groups for menu, border, selection, ghost text, docs, and
  source labels,
- useful but restrained documentation and signature windows,
- better path/file icons through `nvim-web-devicons` and `lspkind`.

#### `blink` behavior direction

- keep `cmdline` enabled and intentionally configured,
- enable signature help,
- keep documentation auto-showing with a reasonable delay,
- keep ghost text restrained,
- disable `blink` snippets completely,
- preserve `Copilot`,
- prefer curated sources over “everything enabled”.

### 4. `blink` sources should be curated around real value

The `blink` stack should focus on sources that improve practical editing:

- `lsp`,
- `path`,
- `buffer`,
- `copilot`,
- `emoji`,
- `dictionary`,
- `ripgrep`.

`snippets` should not be part of the active `blink` source list.

Per-filetype tuning should be used where useful, for example:

- `lua`: prioritize LSP and buffer-like sources cleanly,
- `markdown`/`text`: prefer buffer, path, dictionary, emoji, ripgrep,
- `tex`: keep completion selective to avoid noisy UX.

### 5. `coq` should be a real replacement path, not a stub

The new `coq.lua` file should define:

- `ms-jpq/coq_nvim`,
- `ms-jpq/coq.artifacts`,
- `ms-jpq/coq.thirdparty`,
- integration with existing `copilot.lua`.

Its configuration should include:

- quiet autostart,
- polished popup menu settings,
- preview window settings,
- icon configuration,
- LSP, buffer, path, tree-sitter, and register tuning as appropriate,
- third-party source registration for at least `copilot`, `nvimlua`, and
  `vimtex`,
- keymaps consistent with the rest of the config.

This makes `coq` a usable alternative rather than a historical leftover.

### 6. Cmdline remains a `blink` concern

The local `blink.cmp` documentation explicitly covers cmdline mode in
[docs/plugins/blink.cmp/doc/modes/cmdline.md](/home/papayka/configs/nvim/.config/nvim/docs/plugins/blink.cmp/doc/modes/cmdline.md).

The checked `coq` and `coq.thirdparty` documentation does not provide a
comparably documented cmdline completion source. Therefore:

- `blink` should own cmdline completion when `blink` is the active engine,
- `coq` should not invent undocumented cmdline replacement behavior.

## Component Design

### Shared completion helper

Create a small helper module, for example
[`lua/config/completion.lua`](/home/papayka/configs/nvim/.config/nvim/lua/config/completion.lua),
that centralizes:

- current completion engine (`blink` by default),
- helper `is_blink()` / `is_coq()` predicates,
- `get_lsp_capabilities(capabilities)` wrapper.

Expected behavior:

- if engine is `blink`, call `require("blink.cmp").get_lsp_capabilities(...)`,
- if engine is `coq`, call `require("coq").lsp_ensure_capabilities(...)`,
- otherwise return the capabilities unchanged.

This allows `lsp_and_lang.lua` to stay completion-engine-agnostic.

### `blink.lua`

`blink.lua` should be upgraded in four areas.

#### Plugin dependencies

Keep or add dependencies that support the intended UX:

- `LuaSnip` may remain installed only if needed elsewhere, but `blink`
  completion must not use its snippet source,
- `lspkind.nvim`,
- `blink-emoji.nvim`,
- `blink-cmp-dictionary`,
- `blink-copilot`,
- `blink-ripgrep.nvim`.

#### Menu rendering

Upgrade `completion.menu.draw` to a more structured layout:

- optional item index column,
- icon/kind column,
- main label column,
- detail/description column,
- source label column.

The menu should be information-dense without becoming noisy.

#### Behavior

- `completion.keyword.range = "full"`,
- keep bracket insertion only where useful,
- configure selection so Enter does not feel dangerous in prose buffers,
- enable signature help,
- enable documentation auto-show with a short delay,
- keep `cmdline` enabled and better tuned than the current minimal setup.

#### Highlighting and Copilot interaction

Add explicit highlight setup so the completion surfaces look intentional under
`nord`.

Also add the documented `BlinkCmpMenuOpen` / `BlinkCmpMenuClose` autocmd pattern
to hide inline Copilot suggestions while the blink menu is open, preventing
double-vision UX.

### `coq.lua`

The new `coq.lua` file should be self-contained and only activate when the
shared helper selects the `coq` engine.

The file should define:

- `init` for `vim.g.coq_settings`,
- `config` for third-party source registration,
- any completion-specific keymaps that should only exist in `coq` mode.

The default `coq` source mix should cover:

- LSP,
- buffer text,
- paths,
- built-in snippets/artifacts,
- registers,
- `copilot`,
- `nvimlua`,
- `vimtex` where relevant.

### `lsp_and_lang.lua`

Refactor only the completion-coupled parts:

- replace direct `blink` capability wrapping with the shared helper,
- keep the rest of the server setup intact,
- do not mix new completion concerns into the diagnostic and status utilities.

This keeps scope tight and prevents unnecessary churn.

## Testing Strategy

Verification should cover both static config loading and practical startup.

### Static checks

- headless load of the shared completion helper,
- headless load of `blink.lua`,
- headless load of `coq.lua`,
- headless startup assertions that the chosen engine does not produce Lua errors.

### Runtime checks

- confirm Neovim starts cleanly with default engine = `blink`,
- confirm `blink` completion menu opens with upgraded layout,
- confirm `cmdline` completion still works under `blink`,
- confirm `Copilot` suggestions do not visually clash with the `blink` menu,
- confirm switching engine to `coq` still allows LSP servers to attach with
  proper completion capabilities.

## Implementation Notes

- Keep edits focused to completion-related files.
- Preserve unrelated LSP and UI behavior.
- Do not silently remove `blink`.
- Do not add `blink` snippet completion.
- Prefer documentation-backed options over speculative `coq` features.
