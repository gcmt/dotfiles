local _black = "#2c3238"
local _red = "#ad2f3b"
local _green = "#158045"
local _yellow = "#d2b96c"
local _blue = "#3179b2"
local _magenta = "#9441a6"
local _cyan = "#158cb0"
local _white = "#ffffff"
local _orange = "#c77408"
local _fg_dim = "#6a737d"
local _fg_very_dim = "#a1aab7"
local _fg_super_dim = "#dde5ed"
local _bg_accent = "#f5f6f7"
local _hl_color = "#f7f71b"
local _fg = _black
local _bg = _white
local _cursor = _magenta
local _select_bg = _fg_super_dim

return {

	foreground = _fg,
	background = _bg,
	cursor_bg = _cyan,
	cursor_fg = _bg,
	selection_fg = _fg,
	selection_bg = _select_bg,

	ansi = { _black, _red, _green, _yellow, _blue, _magenta, _cyan, _white },
	brights = { _black, _red, _green, _yellow, _blue, _magenta, _cyan, _white },

	indexed = {
		[16] = _orange,
		[17] = _orange,
		[18] = _fg,
		[19] = _bg,
		[20] = _cursor,
		[21] = _fg_dim,
		[22] = _fg_very_dim,
		[23] = _fg_super_dim,
		[24] = _bg_accent,
		[25] = _hl_color,
		[26] = _select_bg,
	},
}
