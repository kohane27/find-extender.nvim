-- WARNING: Don't mess with this file, i have no idea how i made this work. Now i
-- don't have the capacity to refactor it, as long as it work or if i suddenly
-- become superman and refactor it, there is not need to mess with this file.
-- I will re-write it bug for now i don't wanna break this plugin.
local M = {}

local api = vim.api
local fn = vim.fn

local utils = require("find-extender.utils")

--- manipulates text and puts manipulated text in the register
---@param args table
function M.manipulate_text(args)
    vim.validate({
        match = { args.match, "number" },
        match_direction = { args.match_direction, "table" },
        type = { args.type, "table" },
    })
    local str = api.nvim_get_current_line()
    local register = vim.v.register
    local get_cursor = api.nvim_win_get_cursor(0)

    local match = args.match
    local match_pos_direction = args.match_direction

    local start
    local finish
    if match_pos_direction.right then
        start = match + 1
        finish = get_cursor[2] + 1
    elseif match_pos_direction.left then
        start = get_cursor[2]
        finish = match + 2
    end
    local in_range_str = string.sub(str, start, finish - 1)
    if args.type.delete or args.type.change then
        -- substitute the remaining line from the cursor position till the
        -- next target position
        local remaining_line = utils.get_remaining_str(str, start, finish)
        -- replace the current line with the remaining line
        api.nvim_buf_set_lines(0, get_cursor[1] - 1, get_cursor[1], false, { remaining_line })
        -- if we substitute from right to left the cursor resets to the end
        -- of the line after line gets swapped so we have to get the cursor
        -- position and then set it to the appropriate position
        if match_pos_direction.right then
            get_cursor[2] = get_cursor[2] - #in_range_str + 1
            api.nvim_win_set_cursor(0, get_cursor)
        end
        -- in case of change text start insert after the text gets deleted
        if args.type.change then
            api.nvim_command("startinsert")
        end
    end

    local highlight_on_yank = args.highlight_on_yank
    -- highlight's the yanked area
    if args.type.yank and highlight_on_yank.enable then
        require("find-extender.utils").on_yank(highlight_on_yank, start, finish - 1)
    end

    if get_cursor[2] == 0 then
        in_range_str = string.sub(in_range_str, 1, #in_range_str)
    else
        in_range_str = string.sub(in_range_str, 2, #in_range_str)
    end
    fn.setreg(register, in_range_str)
end

return M
