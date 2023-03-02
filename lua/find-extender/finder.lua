local M = {}
function M.finder(config)
	local api = vim.api
	local fn = vim.fn
	local plugin_enabled = config.enable
	-- how many characters to find for
	local chars_length = config.chars_length
	-- timeout before the find-extender.nvim goes to the default behavior to find 1 char
	-- * timeout in ms
	local timeout = config.timeout
	-- How many characters after which the timeout should be triggered. Important when
	-- we have more set more then _2_ chars lenght in _chars_lenght_.
	local start_timeout_after_chars = config.start_timeout_after_chars -- 2 by default
	-- highlight yanked area
	local yank = config.keymaps.text_manipulation.yank
	-- to remember the last pattern and the command when using the ; and , command
	local _previous_find_info = { pattern = nil, key = nil }

	-- highlight the yanked area
	local function on_yank(start, finish)
		local yank_timer
		local buf_id = api.nvim_get_current_buf()
		local line_nr = fn.getpos(".")[2] - 1

		local buf_ns = api.nvim_create_namespace("my namespace")
		local event = vim.v.event

		if yank_timer then
			yank_timer:close()
		end

		require("vim.highlight").range(
			buf_id,
			buf_ns,
			yank.hl_group,
			{ line_nr, start },
			{ line_nr, finish },
			{ regtype = event.regtype, inclusive = event.inclusive, priority = 200 }
		)
		yank_timer = vim.defer_fn(function()
			yank_timer = nil
			if api.nvim_buf_is_valid(buf_id) then
				api.nvim_buf_clear_namespace(buf_id, buf_ns, 0, -1)
			end
		end, yank.timeout)
	end

	local function reverse_tbl(tbl)
		local transformed_tbl = {}
		local idx = #tbl
		while true do
			table.insert(transformed_tbl, tbl[idx])
			if idx < 1 then
				break
			end
			idx = idx - 1
		end
		return transformed_tbl
	end

	-- maps the occurrences of the pattern in a string
	local function map_string_nodes(string, pattern)
		local mapped_tbl = {}
		local pattern_last_idx = mapped_tbl[#mapped_tbl] or 1
		while true do
			local pattern_idx = string.find(string, pattern, pattern_last_idx, true)
			if not pattern_idx then
				break
			end
			table.insert(mapped_tbl, pattern_idx)
			pattern_last_idx = mapped_tbl[#mapped_tbl] + 2
		end
		return mapped_tbl
	end

	local function node_validation(string_end_position, str)
		local string = string.sub(str, 1, string_end_position)
		local i = 0
		for _ in string.gmatch(string, "%a") do
			i = i + 1
		end
		if i > 1 then
			return false
		end
		return true
	end

	local function get_node(pattern, direction, threshold, skip_nodes)
		local get_cursor = api.nvim_win_get_cursor(0)
		local current_line = api.nvim_get_current_line()
		local string_nodes = map_string_nodes(current_line, pattern)

		local cursor_position = get_cursor[2]
		local node = nil
		-- in cases of node in the start of the line and node in the end of the
		-- line we need to reset the threshold
		local reset_threshold = false
		-- direction is to know which direction to search in
		if direction.left then
			for node_position, current_node in ipairs(string_nodes) do
				if
					cursor_position + threshold < current_node
					or cursor_position < 1 and current_node < 3
				then
					if
						threshold > 1
						and node_validation(current_node, current_line)
						and not skip_nodes
					then
						reset_threshold = true
					end
					if skip_nodes then
						node = string_nodes[node_position + skip_nodes - 1]
					else
						node = current_node
					end
					break
				end
			end
		elseif direction.right then
			-- need to reverse the tbl of the string_nodes because now
			-- we have to start searching from the end of the string rather then from
			-- the start
			string_nodes = reverse_tbl(string_nodes)
			for node_position, current_node in ipairs(string_nodes) do
				if
					cursor_position - threshold == current_node
					or cursor_position - threshold > current_node
				then
					if threshold > 1 and node_validation(current_node, current_line) then
						reset_threshold = true
					end
					if skip_nodes then
						local x = string_nodes[node_position + skip_nodes - 1]
						-- need to reset the threshold here because previous
						-- guard wasn't for this x node
						if threshold > 1 and node_validation(x, current_line) then
							reset_threshold = true
						end
						node = x
					else
						node = current_node
					end
					break
				end
			end
		end
		if node then
			if reset_threshold then
				threshold = 1
			end
			cursor_position = node - threshold
		else
			cursor_position = nil
		end
		return cursor_position
	end

	local function get_remaining_str(str, before_end, after_start)
		local a = string.sub(str, 1, before_end)
		local b = string.sub(str, after_start, #str)
		return a .. b
	end

	-- don't disturb this function
	local function manipulate_text(pattern, direction, threshold, skip_nodes, types)
		local current_line = api.nvim_get_current_line()
		local register = vim.v.register
		local get_cursor = api.nvim_win_get_cursor(0)
		local target_position = get_node(pattern, direction, threshold, skip_nodes)
		if not target_position then
			return
		end
		local start
		local finish
		if direction.right then
			start = target_position + 1
			finish = get_cursor[2]
		elseif direction.left then
			start = get_cursor[2]
			finish = target_position
		end
		if direction.left then
			finish = finish + 1
		end
		if get_cursor[2] == 0 and target_position == 1 and threshold == 2 then
			return
		end
		local range_str = string.sub(current_line, start, finish)
		if types.delete or types.change then
			-- to go one character more then we usually do when finding a
			-- character think of it as a syntactic sugar to make it fill like we
			-- are deleting or changing till a pattern
			finish = finish + 1
			-- substitute the remaining line from the cursor position till the
			-- next target position
			local remaining_line = get_remaining_str(current_line, start, finish)
			-- replace the current line with the remaining line
			api.nvim_buf_set_lines(0, get_cursor[1] - 1, get_cursor[1], false, { remaining_line })
			-- if we substitute from right to left the cursor resets to the end
			-- of the line after line gets swapped so we have to get the cursor
			-- position and then set it to the appropriate position
			if direction.right then
				get_cursor[2] = get_cursor[2] - #range_str + 1
				api.nvim_win_set_cursor(0, get_cursor)
			end
			-- in case of change text start insert after the text gets deleted
			if types.change then
				api.nvim_command("startinsert")
			end
		end
		if types.yank then
			on_yank(start, finish)
		end
		-- NOTE> we are doing this text substitution using lua string.sub which
		-- isn't same as the nvim's delete or change so we have to adjust how
		-- much characters we got into our register in some case we have to sometimes
		-- discard one character.
		if direction.left then
			if get_cursor[2] == 0 then
				range_str = string.sub(range_str, 1, #range_str)
			else
				range_str = string.sub(range_str, 2, #range_str)
			end
		elseif direction.right then
			range_str = string.sub(range_str, 2, #range_str)
		end
		fn.setreg(register, range_str)
	end

	local function set_cursor(pattern, direction, threshold, skip_nodes)
		local get_cursor = api.nvim_win_get_cursor(0)
		local target_position = get_node(pattern, direction, threshold, skip_nodes)
		if not target_position then
			return
		end
		get_cursor[2] = target_position
		api.nvim_win_set_cursor(0, get_cursor)
	end

	local function get_chars()
		local break_loop = false
		local chars = ""
		local i = 0
		while true do
			if timeout and #chars > start_timeout_after_chars - 1 then
				-- this is a trick to solve issue of multiple timers being
				-- created and once the guard condition becomes true the previous
				-- timers jeopardised the timeout
				-- So for now the i and id variable's acts as a id validation
				i = i + 1
				local id = i
				vim.defer_fn(function()
					if i == id then
						-- to get rid of the getchar will throw dummy value which won't
						-- be added to the chars list
						api.nvim_feedkeys("�", "n", false)
						break_loop = true
					end
				end, timeout)
			end
			local c = fn.getchar()
			if type(c) ~= "number" then
				return
			end
			if break_loop then
				return chars
			elseif c < 32 or c > 127 then
				-- only accept ASCII value for the letters and punctuations including
				-- space as input
				return
			end
			chars = chars .. fn.nr2char(c)
			if #chars == chars_length then
				break
			end
		end
		return chars
	end

	local function find_target(key)
		-- to get the count
		local skip_nodes = vim.v.count
		if skip_nodes < 2 then
			skip_nodes = nil
		end
		-- if no find command was executed previously then there's no last pattern for
		-- , or ; so return
		if not _previous_find_info.pattern and key == "," or key == ";" and not _previous_find_info.pattern then
			return
		end
		-- to determine which direction to go
		-- THIS is the only way i found efficient without heaving overhead
		-- > find
		local find_direction_left = key == "f"
			or _previous_find_info.key == "F" and key == ","
			or _previous_find_info.key == "f" and key == ";"
			or key == "cf"
			or key == "df"
			or key == "yf"
		local find_direction_right = key == "F"
			or _previous_find_info.key == "f" and key == ","
			or _previous_find_info.key == "F" and key == ";"
			or key == "cF"
			or key == "dF"
			or key == "yF"
		-- > till
		local till_direction_left = key == "t"
			or _previous_find_info.key == "T" and key == ","
			or _previous_find_info.key == "t" and key == ";"
			or key == "ct"
			or key == "dt"
			or key == "yt"
		local till_direction_right = key == "T"
			or _previous_find_info.key == "t" and key == ","
			or _previous_find_info.key == "T" and key == ";"
			or key == "cT"
			or key == "dT"
			or key == "yT"

		local direction = { left = false, right = false }
		if find_direction_right or till_direction_right then
			direction.right = true
		elseif find_direction_left or till_direction_left then
			direction.left = true
		end
		-- this variable is threshold between the pattern under the cursor position
		-- it it exists the pattern exists within this threshold then move to the
		-- next one or previous one depending on the key
		local threshold = nil
		if till_direction_left or till_direction_right then
			threshold = 2
		elseif find_direction_left or find_direction_right then
			threshold = 1
		end

		local chars_pattern
		local normal_keys = key == "f" or key == "F" or key == "t" or key == "T"
		local text_manipulation_keys = key == "cT"
			or key == "dT"
			or key == "yT"
			or key == "ct"
			or key == "dt"
			or key == "yt"
			or key == "cf"
			or key == "df"
			or key == "yf"
			or key == "cF"
			or key == "dF"
			or key == "yF"

		if normal_keys then
			-- if find or till command is executed then add the pattern and the key to the
			-- _last_search_info table.
			chars_pattern = get_chars()
			if not chars_pattern then
				return
			end
			_previous_find_info.key = key
			_previous_find_info.pattern = chars_pattern
		elseif text_manipulation_keys then
			chars_pattern = get_chars()
			if not chars_pattern then
				return
			end
		else
			-- if f or F or t or T command wasn't pressed then search for the _last_search_info.pattern
			-- for , or ; command
			chars_pattern = _previous_find_info.pattern
		end
		local text_manipulation_types = { change = false, yank = false, delete = false }
		if #key > 1 then
			local type = string.sub(key, 1, 1)
			if type == "c" then
				text_manipulation_types.change = true
			elseif type == "d" then
				text_manipulation_types.delete = true
			elseif type == "y" then
				text_manipulation_types.yank = true
			end
			manipulate_text(chars_pattern, direction, threshold, skip_nodes, text_manipulation_types)
		else
			set_cursor(chars_pattern, direction, threshold, skip_nodes)
		end
	end

	local function merge_tables(tbl_a, tbl_b)
		for _, val in pairs(tbl_a) do
			table.insert(tbl_b, val)
		end
		return tbl_b
	end

	local keys_tbl = {
		-- these keys aren't optional
		";",
		",",
	}
	local text_manipulation_keys = {}

	local modes_tbl = {}

	local function notify(msg)
		local level = vim.log.levels.WARN
		vim.api.nvim_notify(msg, level, {})
	end

	local keymaps = config.keymaps
	keys_tbl = merge_tables(keymaps.find, keys_tbl)
	keys_tbl = merge_tables(keymaps.till, keys_tbl)
	if keymaps.text_manipulation then
		local type = keymaps.text_manipulation
		if type.yank then
			local keys = { "yf", "yF", "yt", "yT" }
			text_manipulation_keys = merge_tables(keys, text_manipulation_keys)
		end
		if type.delete then
			local keys = { "df", "dF", "dt", "dT" }
			text_manipulation_keys = merge_tables(keys, text_manipulation_keys)
		end
		if type.change then
			local keys = { "cf", "cF", "ct", "cT" }
			text_manipulation_keys = merge_tables(keys, text_manipulation_keys)
		end
	end

	local modes = keymaps.modes
	if #modes > 0 then
		-- adding modes to the list
		for i = 1, #modes, 1 do
			local mode = string.sub(modes, i, i)
			table.insert(modes_tbl, mode)
		end
	else
		notify("find-extender.nvim: no modes provided in keymaps table.")
	end

	local set_keymap = vim.keymap.set
	local function set_maps()
		for _, key in ipairs(keys_tbl) do
			set_keymap(modes_tbl, key, function()
				find_target(key)
			end)
		end
		for _, key in ipairs(text_manipulation_keys) do
			set_keymap("n", key, function()
				find_target(key)
			end)
		end
	end

	local function remove_maps()
		for _, key in ipairs(keys_tbl) do
			set_keymap(modes_tbl, key, key)
		end
		for _, key in ipairs(text_manipulation_keys) do
			set_keymap("n", key, function()
				set_keymap(modes_tbl, key, key)
			end)
		end
	end

	local function enable_plugin()
		plugin_enabled = true
		set_maps()
	end
	local function disable_plugin()
		plugin_enabled = false
		remove_maps()
	end

	-- create the commands for the plugin
	local cmds = {
		["FindExtenderDisable"] = function()
			disable_plugin()
		end,
		["FindExtenderEnable"] = function()
			enable_plugin()
		end,
		["FindExtenderToggle"] = function()
			if plugin_enabled then
				disable_plugin()
			else
				enable_plugin()
			end
		end,
	}
	for cmd_name, cmd_func in pairs(cmds) do
		api.nvim_create_user_command(cmd_name, function()
			cmd_func()
		end, {})
	end

	-- enable plugin on startup if it was enabled
	if plugin_enabled then
		enable_plugin()
	end
end

return M
