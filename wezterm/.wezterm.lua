local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 12
config.line_height = 1.2
config.cell_width = 1.2
config.font = wezterm.font "Roboto Mono"
config.window_close_confirmation = "NeverPrompt"
config.freetype_load_target = "Normal"
config.front_end = "WebGpu"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

local colorscheme = "dark"

local _black          = "#1e222b"
local _red            = "#945f65"
local _green          = "#768a78"
local _yellow         = "#a39465"
local _blue           = "#657b99"
local _magenta        = "#917086"
local _cyan           = "#739492"
local _white          = "#8e9299"
local _orange         = "#998068"
local _fg_dim         = "#6d717a"
local _fg_very_dim    = "#565a66"
local _fg_super_dim   = "#2f333d"
local _bg_accent      = "#252933"
local _hl_color       = "#a39465"
local _fg             = _white
local _bg             = _black
local _cursor         = _magenta
local _select_bg      = _fg_super_dim

config.colors = {

    foreground = _fg,
    background = _bg,
    cursor_bg = _magenta,
    cursor_fg = _bg,
    selection_fg = _fg,
    selection_bg = _select_bg,

    ansi = {_black, _red, _green, _yellow, _blue, _magenta, _cyan, _white},
    brights = {_black, _red, _green, _yellow, _blue, _magenta, _cyan, _white},

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
    }
}

return config
