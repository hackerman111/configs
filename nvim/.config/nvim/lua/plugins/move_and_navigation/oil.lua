-- ~/.config/nvim/lua/plugins/word-motion-hints.lua

return {
    {
        "tris203/precognition.nvim",
        event = "VeryLazy",
        config = function()
            require("precognition").setup({
                startVisible = false,
            })

            local ns = vim.api.nvim_create_namespace("word-motion-hints")

            local enabled = true
            local scheduled = false

            local cfg = {
                -- j/k показывать только в пределах N строк
                max_vertical_distance = 12,

                -- h/l показывать только в пределах N символов
                max_horizontal_distance = 40,

                -- Слова как в коде: foo, bar_1, my_var
                -- Для любых непробельных токенов замени на "%S+"
                word_pattern = "%S+",

                excluded_filetypes = {
                    ["neo-tree"] = true,
                    ["NvimTree"] = true,
                    ["TelescopePrompt"] = true,
                    ["lazy"] = true,
                    ["mason"] = true,
                    ["notify"] = true,
                },
            }

            vim.api.nvim_set_hl(0, "MotionHintJK", {
                link = "Comment",
                default = true,
            })

            vim.api.nvim_set_hl(0, "MotionHintHL", {
                link = "DiagnosticHint",
                default = true,
            })

            local function valid_buffer(buf)
                if not vim.api.nvim_buf_is_valid(buf) then
                    return false
                end

                if vim.bo[buf].buftype ~= "" then
                    return false
                end

                if cfg.excluded_filetypes[vim.bo[buf].filetype] then
                    return false
                end

                return true
            end

            local function char_col(line, byte_col)
                if byte_col <= 0 then
                    return 0
                end

                return vim.fn.strchars(line:sub(1, byte_col))
            end

            local function iter_words(line)
                local result = {}

                for start_pos, end_pos in line:gmatch("()" .. cfg.word_pattern .. "()") do
                    table.insert(result, {
                        start_byte = start_pos - 1,
                        end_byte = end_pos - 1,
                    })
                end

                return result
            end

            local function first_word_end(line)
                for _, word in ipairs(iter_words(line)) do
                    return word.end_byte
                end

                local first_nonblank = line:find("%S")
                if first_nonblank then
                    return first_nonblank - 1
                end

                return 0
            end

            local function put_hint(buf, row, col, text, hl_group, priority)
                local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
                col = math.max(0, math.min(col, #line))

                vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
                    virt_text = {
                        { " " .. text, hl_group },
                    },

                    -- Ставит подсказку прямо после слова.
                    -- Минус: inline virtual text визуально сдвигает текст вправо.
                    virt_text_pos = "inline",

                    hl_mode = "combine",
                    priority = priority or 2000,
                })
            end

            local function render()
                if not enabled then
                    return
                end

                local win = vim.api.nvim_get_current_win()
                local buf = vim.api.nvim_win_get_buf(win)

                if not valid_buffer(buf) then
                    return
                end

                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

                local cursor = vim.api.nvim_win_get_cursor(win)
                local cursor_lnum = cursor[1]
                local cursor_byte_col = cursor[2]

                local info = vim.fn.getwininfo(win)[1]
                if not info then
                    return
                end

                local top = info.topline
                local bottom = info.botline

                local lines = vim.api.nvim_buf_get_lines(buf, top - 1, bottom, false)

                for i, line in ipairs(lines) do
                    local lnum = top + i - 1
                    local row = lnum - 1

                    if lnum == cursor_lnum then
                        local cursor_char_col = char_col(line, cursor_byte_col)

                        for _, word in ipairs(iter_words(line)) do
                            local inside_word =
                                cursor_byte_col >= word.start_byte
                                and cursor_byte_col < word.end_byte

                            if not inside_word then
                                local target_char_col = char_col(line, word.start_byte)
                                local dist = math.abs(target_char_col - cursor_char_col)

                                if dist > 0 and dist <= cfg.max_horizontal_distance then
                                    local motion = target_char_col > cursor_char_col and "l" or "h"

                                    put_hint(
                                        buf,
                                        row,
                                        word.end_byte,
                                        tostring(dist) .. motion,
                                        "MotionHintHL",
                                        2100
                                    )
                                end
                            end
                        end
                    else
                        local dist = math.abs(lnum - cursor_lnum)

                        if dist > 0 and dist <= cfg.max_vertical_distance then
                            local motion = lnum > cursor_lnum and "j" or "k"
                            local col = first_word_end(line)

                            put_hint(
                                buf,
                                row,
                                col,
                                tostring(dist) .. motion,
                                "MotionHintJK",
                                2000
                            )
                        end
                    end
                end
            end

            local function schedule_render()
                if scheduled then
                    return
                end

                scheduled = true

                vim.schedule(function()
                    scheduled = false
                    render()
                end)
            end

            local function clear()
                local buf = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            end

            vim.api.nvim_create_user_command("WordMotionHintsToggle", function()
                enabled = not enabled

                if enabled then
                    render()
                    vim.notify("word-motion-hints: enabled")
                else
                    clear()
                    vim.notify("word-motion-hints: disabled")
                end
            end, {})

            vim.keymap.set("n", "<leader>uh", function()
                vim.cmd("WordMotionHintsToggle")
            end, {
                desc = "Toggle word motion hints",
            })

            local group = vim.api.nvim_create_augroup("WordMotionHints", {
                clear = true,
            })

            vim.api.nvim_create_autocmd({
                "CursorMoved",
                "CursorMovedI",
                "WinScrolled",
                "BufEnter",
                "WinEnter",
                "TextChanged",
                "TextChangedI",
            }, {
                group = group,
                callback = schedule_render,
            })

            vim.api.nvim_create_autocmd("BufLeave", {
                group = group,
                callback = clear,
            })
        end,
    },
}
