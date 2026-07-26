# Python completion owner

## Goal

Prevent duplicate Python completion entries in blink while retaining both
`ty` and `pyrefly` diagnostics.

## Design

`ty` is the sole Python LSP completion provider. During `LspAttach`,
`pyrefly` keeps its diagnostic and navigation capabilities, but its
`completionProvider` server capability is cleared before blink requests
completion items. Ruff remains responsible for lint-related features and does
not provide completion.

No blink-side label filtering is added: duplicate candidates are prevented at
the source instead of being discarded after collection.

## Verification

Open a Python buffer in a fresh headless Neovim instance and confirm:

- `ty` supports `textDocument/completion`;
- `pyrefly` and `ruff` do not;
- blink returns one entry for a locally declared test variable.
