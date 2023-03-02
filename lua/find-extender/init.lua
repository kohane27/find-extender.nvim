local M = {}
function M.setup(user_config)
	local default_config = {
		enable = true,
		chars_length = 2,
		timeout = false,
		start_timeout_after_chars = 1,
		keymaps = {
			modes = "nv",
			till = { "T", "t" },
			find = { "F", "f" },
			text_manipulation = {
				yank = {
					highlight_on_yank = true,
					timeout = 80,
					hl_group = "IncSearch",
				},
				delete = true,
				change = true,
			},
		},
	}
	-- merge the user config and the default config
	local config = vim.tbl_extend("force", default_config, user_config or {})

	-- merge the user keymaps and default keymaps
	config.keymaps = vim.tbl_extend("force", default_config.keymaps, config.keymaps)

	require("find-extender.finder").finder(config)
end

return M
