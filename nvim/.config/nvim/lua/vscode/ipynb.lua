-- ~/.config/nvim/lua/vscode/ui.lua
-- VS Code UI control through VSCode Neovim.
-- Add to init.lua:
--   if vim.g.vscode then require("vscode.ui") end

if not vim.g.vscode then
  return
end

local vscode = require("vscode")

local function act(name)
  return function()
    vscode.action(name)
  end
end

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- UI toggles
map("n", "<leader>e", act("workbench.action.toggleSidebarVisibility"), opts)
map("n", "<leader>f", act("workbench.action.quickOpen"), opts)
map("n", "<leader>p", act("workbench.action.showCommands"), opts)
map("n", "<leader>t", act("workbench.action.terminal.toggleTerminal"), opts)
map("n", "<leader>z", act("workbench.action.toggleZenMode"), opts)
map("n", "<leader>x", act("workbench.actions.view.problems"), opts)
map("n", "<leader>g", act("workbench.view.scm"), opts)

-- Splits / groups
map("n", "<C-h>", act("workbench.action.navigateLeft"), opts)
map("n", "<C-j>", act("workbench.action.navigateDown"), opts)
map("n", "<C-k>", act("workbench.action.navigateUp"), opts)
map("n", "<C-l>", act("workbench.action.navigateRight"), opts)
map("n", "<leader>sv", act("workbench.action.splitEditorRight"), opts)
map("n", "<leader>sh", act("workbench.action.splitEditorDown"), opts)
map("n", "<leader>q", act("workbench.action.closeActiveEditor"), opts)
map("n", "H", act("workbench.action.previousEditor"), opts)
map("n", "L", act("workbench.action.nextEditor"), opts)

-- Notebook commands
map("n", "]]", act("notebook.focusNextEditor"), opts)
map("n", "[[", act("notebook.focusPreviousEditor"), opts)
map("n", "<leader>rr", act("notebook.cell.execute"), opts)
map("n", "<leader>rj", act("notebook.cell.executeAndSelectBelow"), opts)
map("n", "<leader>ra", act("notebook.cell.executeCellsAbove"), opts)
map("n", "<leader>rb", act("notebook.cell.executeCellAndBelow"), opts)
map("n", "<leader>ca", act("notebook.cell.insertCodeCellAbove"), opts)
map("n", "<leader>cb", act("notebook.cell.insertCodeCellBelow"), opts)
map("n", "<leader>cm", act("notebook.cell.changeToMarkdown"), opts)
map("n", "<leader>cc", act("notebook.cell.changeToCode"), opts)
map("n", "<leader>cd", act("notebook.cell.delete"), opts)
map("n", "<leader>co", act("notebook.cell.toggleOutputs"), opts)
map("n", "<leader>cl", act("notebook.cell.clearOutputs"), opts)
