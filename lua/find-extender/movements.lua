local M = {}

local api = vim.api
local fn = vim.fn
local utils = require("find-extender.utils")

--- leap movment
---@param args table
---@return number|nil picked match
function M.leap(args)
	local picked_match = nil
	local buf_nr = api.nvim_get_current_buf()
	local line_nr = fn.line(".")
	local ns_id = api.nvim_create_namespace("")
	-- need exact location to highlight target position with respect to the key
	-- type threshold, which differs in find and till
	local threshold = nil
	if args.key_type.find then
		threshold = 1
	elseif args.key_type.till then
		threshold = 2
	end
	local i = 1
	for _, match in ipairs(args.matches) do
		local extmark_opts = {
			virt_text = { { string.sub(args.symbols, i, i), "FEVirtualText" } },
			virt_text_pos = "overlay",
			hl_mode = "combine",
			priority = 105,
		}
		api.nvim_buf_set_extmark(buf_nr, ns_id, line_nr - 1, match - threshold, extmark_opts)
		i = i + 1
	end
	api.nvim_create_autocmd({ "CursorMoved" }, {
		once = true,
		callback = function()
			api.nvim_buf_clear_namespace(buf_nr, ns_id, 0, -1)
		end,
	})
	picked_match = utils.get_chars({ chars_length = 1 })
	if picked_match then
		local match_pos = string.find(args.symbols, picked_match)
		picked_match = args.matches[match_pos]
	end
	vim.cmd("silent! do CursorMoved")

	return picked_match
end

--- lh movment
---@param args table
---@return number|nil picked match
M.lh = function(args)
	local picked_match = nil
	local buf_nr = api.nvim_get_current_buf()
	local cursor_pos = fn.getpos(".")[3]
	local line_nr = fn.line(".")
	local ns_id = api.nvim_create_namespace("")
	-- this table of matches is for the use of h key for backward movmenet,
	-- because we mapped the string from left to right in case of the h key it
	-- will break the loop on the first match, that why we have to reverse this table.
	local args_matches_reversed = utils.reverse_tbl(args.matches)
	for _, match in ipairs(args.matches) do
		api.nvim_buf_add_highlight(buf_nr, ns_id, "FEVirtualText", line_nr - 1, match - 1, match + 1)
	end
	picked_match = cursor_pos
	local lh_cursor_ns = api.nvim_create_namespace("")
	local function render_cursor(match)
		api.nvim_buf_clear_namespace(buf_nr, lh_cursor_ns, 0, -1)
		-- need to add the cursor highlight at the exact location relative to the key type
		local threshold = nil
		if args.key_type.find then
			threshold = 1
		elseif args.key_type.till then
			threshold = 2
		end
		api.nvim_buf_add_highlight(buf_nr, lh_cursor_ns, "FECurrentMatchCursor", line_nr - 1, match - threshold, match)
	end
	while true do
		local key = utils.get_chars({ chars_length = 1, accept_keymaps = { 27, 13 }, no_dummy_cursor = true })
		vim.cmd("do CursorMoved")
		if key == "l" then
			local __matches = nil
			if args.direction.left then
				__matches = args.matches
			else
				__matches = args_matches_reversed
			end
			for _, match in ipairs(__matches) do
				if match > picked_match then
					picked_match = match
					render_cursor(match)
					break
				end
			end
		end
		if key == "h" then
			local __matches = nil
			if args.direction.left then
				__matches = args_matches_reversed
			else
				__matches = args.matches
			end
			for _, match in ipairs(__matches) do
				if match < picked_match then
					picked_match = match
					render_cursor(match)
					break
				end
			end
		end
		-- if <CR> then accept the current position
		-- else go to the original position
		if key == 13 then
			break
		elseif key == 27 then
			picked_match = nil
			break
		end
	end
	api.nvim_buf_clear_namespace(buf_nr, ns_id, 0, -1)
	api.nvim_buf_clear_namespace(buf_nr, lh_cursor_ns, 0, -1)
	return picked_match
end

return M
