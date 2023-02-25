local M = {}
-- TODO: add the enable = true if it was disabled using command line then remove
-- the mappings and add the default find and till maps if it was disabled from
-- the setup function then don't add maps
-- And add the command line option to disable this plugin
function M.setup(user_config)
	local default_config = {
		chars_length = 2,
		timeout = false,
		start_timeout_after_chars = 1,
		keymaps = {
			modes = "nv",
			till = { "T", "t" },
			find = { "F", "f" },
		},
	}
	-- merge the user config and the default config
	local config = vim.tbl_extend("force", default_config, user_config or {})

	-- merge the user keymaps and default keymaps
	config.keymaps = vim.tbl_extend("force", default_config.keymaps, config.keymaps)

	require("find-extender.finder").finder(config)
end

return M
