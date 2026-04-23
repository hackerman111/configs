local M = {}

local function empty_response(callback)
	callback({
		isIncomplete = true,
		items = {},
	})
end

local function first_line(text)
	text = tostring(text or ""):gsub("\r\n", "\n")
	return text:match("^[^\n]*") or ""
end

local function utf16_len(text)
	local ok, util = pcall(require, "copilot.util")
	if ok and type(util.strutf16len) == "function" then
		return util.strutf16len(text)
	end

	return vim.fn.strchars(text)
end

function M.item_from_completion(completion, index, filetype)
	local text = completion.text or completion.displayText
	if type(text) ~= "string" or text == "" then
		return nil
	end

	local label = vim.trim(first_line(completion.displayText or text))
	if label == "" then
		label = "Copilot suggestion"
	end

	local uuid = completion.uuid
	local item = {
		label = label,
		kind = vim.lsp.protocol.CompletionItemKind.Text,
		detail = "Copilot",
		documentation = {
			kind = "markdown",
			value = ("```%s\n%s\n```"):format(filetype or "", text),
		},
		filterText = label,
		sortText = ("%04d"):format(index),
		insertText = text,
		command = uuid and {
			title = "Copilot accepted",
			command = "copilot.accepted",
			arguments = { uuid, utf16_len(text) },
		} or nil,
	}

	if type(completion.range) == "table" then
		item.textEdit = {
			range = completion.range,
			newText = text,
		}
	end

	return item
end

local function get_copilot_client(bufnr)
	local ok_client, client_mod = pcall(require, "copilot.client")
	if not ok_client then
		return nil
	end

	pcall(client_mod.buf_attach, false, bufnr)
	return client_mod.get()
end

function M.complete(spec, args, callback)
	local ok_api, api = pcall(require, "copilot.api")
	local ok_util, util = pcall(require, "copilot.util")
	if not ok_api or not ok_util then
		empty_response(callback)
		return nil
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local client = get_copilot_client(bufnr)
	if not client then
		empty_response(callback)
		return nil
	end

	local done = false
	local cancelled = false
	local max_items = tonumber(spec.max_items) or 3

	local function respond(resp)
		if done or cancelled then
			return
		end
		done = true
		callback(resp)
	end

	local params = util.get_doc_params()
	params.bufnr = bufnr

	local ok, sent, request_id = pcall(api.get_completions, client, params, function(err, data)
		if err or type(data) ~= "table" then
			respond({ isIncomplete = true, items = {} })
			return
		end

		local items = {}
		for index, completion in ipairs(data.completions or {}) do
			if #items >= max_items then
				break
			end

			local item = M.item_from_completion(completion, index, vim.bo[bufnr].filetype)
			if item then
				table.insert(items, item)
			end
		end

		respond({
			isIncomplete = true,
			items = items,
		})
	end)

	if not ok or not sent then
		respond({ isIncomplete = true, items = {} })
		return nil
	end

	return function()
		cancelled = true
		if request_id then
			pcall(client.cancel_request, client, request_id)
		end
	end
end

function M.exec(args, callback)
	local arguments = args.arguments or {}
	local uuid = arguments.uuid or arguments[1]
	local accepted_length = arguments.acceptedLength or arguments[2]
	local client = get_copilot_client(vim.api.nvim_get_current_buf())
	local ok_api, api = pcall(require, "copilot.api")

	if ok_api and client and uuid then
		api.notify_accepted(client, { uuid = uuid, acceptedLength = accepted_length }, function() end)
	end

	if callback then
		callback({})
	end
end

function M.source(spec)
	spec = spec or {}

	local fn = function(args, callback)
		return M.complete(spec, args, callback)
	end

	local exec = function(args, callback)
		return M.exec(args, callback)
	end

	return fn, { exec = exec }
end

return M
