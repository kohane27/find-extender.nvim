local M = {}

local api = vim.api
local fn = vim.fn
local utils = require("find-extender.utils")

--- leap movement
---@param args table
---@return number|nil picked match
function M.leap(args)
    local buf_nr = api.nvim_get_current_buf()
    local line_nr = fn.line(".")
    local ns_id = api.nvim_create_namespace("")
    local i = 1
    for _, match in ipairs(args.matches) do
        local extmark_opts = {
            virt_text = { { string.sub(args.symbols, i, i), "FEVirtualText" } },
            virt_text_pos = "overlay",
            hl_mode = "combine",
            priority = 105,
        }
        -- need to normalize this for cases where the `input_length` is 1 or if
        -- input was `no_wait` char
        if not (args.virt_hl_length > 0) then
            args.virt_hl_length = 1
        end
        api.nvim_buf_set_extmark(buf_nr, ns_id, line_nr - 1, match - args.virt_hl_length, extmark_opts)
        i = i + 1
    end
    local picked_match = nil
    local picked_virt_text = utils.get_chars({ input_length = 1 })
    if picked_virt_text and type(picked_virt_text) == "string" then
        -- get the index for the match
        local match_pos = string.find(args.symbols, picked_virt_text)
        -- retrieve match from the matches
        picked_match = args.matches[match_pos]
    end
    api.nvim_buf_clear_namespace(buf_nr, ns_id, 0, -1)
    return picked_match
end

return M
