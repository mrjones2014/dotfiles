local w = require("wezterm")
local keymaps = require("keymaps")

local os_name
local function os()
	if os_name then
		return os_name
	end
	local binary_format = package.cpath:match("%p[\\|/]?%p(%a+)")
	if binary_format == "dll" then
		os_name = "Windows"
	elseif binary_format == "so" then
		os_name = "Linux"
	elseif binary_format == "dylib" then
		os_name = "MacOS"
	end
end

local config = {
	cursor_blink_rate = 0,
	font = w.font("FiraCode Nerd Font"),
	font_size = 14,
	use_fancy_tab_bar = true,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	window_padding = {
		top = 0,
		bottom = 0,
		left = 0,
		right = 0,
	},
	debug_key_events = true,
	leader = keymaps.leader,
	keys = keymaps.keys,
}

if os() == "MacOS" then
	config.window_decorations = "RESIZE"
end

return config
