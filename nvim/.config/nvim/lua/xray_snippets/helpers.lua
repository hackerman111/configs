local M = {}

function M.extend(dst, src)
    for _, item in ipairs(src) do
        table.insert(dst, item)
    end
    return dst
end

function M.assert_unique_triggers(snippets)
    local seen = {}

    for _, snippet in ipairs(snippets) do
        local trigger = snippet.trigger

        if not trigger then
            error("Xray snippet without trigger")
        end

        if seen[trigger] then
            error(("duplicate Xray snippet trigger: %s"):format(trigger))
        end

        seen[trigger] = true
    end
end

return M
