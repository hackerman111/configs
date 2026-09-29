-- ~/.config/nvim/lua/vscode/notebook_nav.lua
-- Auto jump between VS Code notebook cells when cursor reaches cell edge.

if not vim.g.vscode then
    return
end

local vscode = require("vscode")

local function normal(keys)
    vim.cmd("normal! " .. keys)
end

local function feed_normal(keys)
    local term = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(term, "n", false)
end

local function move_down()
    local count = vim.v.count1
    local current = vim.fn.line(".")
    local last = vim.fn.line("$")

    if current + count > last then
        vscode.action("notebook.focusNextEditor")
    else
        normal(count .. "j")
    end
end

local function move_up()
    local count = vim.v.count1
    local current = vim.fn.line(".")

    if current - count < 1 then
        vscode.action("notebook.focusPreviousEditor")
    else
        normal(count .. "k")
    end
end

local function move_visual_down()
    local current = vim.fn.line(".")
    local last = vim.fn.line("$")

    if current >= last then
        vscode.action("notebook.focusNextEditor")
    else
        normal("gj")
    end
end

local function move_visual_up()
    local current = vim.fn.line(".")

    if current <= 1 then
        vscode.action("notebook.focusPreviousEditor")
    else
        normal("gk")
    end
end

local opts = { silent = true, noremap = true }

-- Regular Vim line movement.
vim.keymap.set("n", "j", move_down, opts)
vim.keymap.set("n", "k", move_up, opts)

-- Wrapped-line movement, useful in Markdown/text-heavy cells.
vim.keymap.set("n", "gj", move_visual_down, opts)
vim.keymap.set("n", "gk", move_visual_up, opts)

-- Arrow keys too, if you sometimes use them.
vim.keymap.set("n", "<Down>", move_down, opts)
vim.keymap.set("n", "<Up>", move_up, opts)

-- Explicit cell jumps stay available.
vim.keymap.set("n", "]]", function()
    vscode.action("notebook.focusNextEditor")
end, opts)

vim.keymap.set("n", "[[", function()
    vscode.action("notebook.focusPreviousEditor")
end, opts)
