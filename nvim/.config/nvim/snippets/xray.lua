local helpers = require("xray_snippets.helpers")

local snippets = {}

helpers.extend(snippets, require("xray_snippets.core"))
helpers.extend(snippets, require("xray_snippets.protocols"))
helpers.extend(snippets, require("xray_snippets.transports"))
helpers.extend(snippets, require("xray_snippets.scenarios"))
helpers.assert_unique_triggers(snippets)

return snippets
