#!/bin/bash

declare -A colors
colors[nc]=$(tput sgr0)
colors[red]=$(tput setaf 1)
colors[green]=$(tput setaf 2)
colors[white]=$(tput setaf 7)

if [[ "$*" =~ -all($| ) ]]; then
	all=yes
fi

dotdir="$(cd "$(dirname "$0")" && pwd)"

source "$dotdir/zsh/.zshenv"

if [[ -z "$XDG_CONFIG_HOME" || -z "$XDG_CACHE_HOME" || -z "$XDG_DATA_HOME" ]]; then
	echo >&2 'XDG directories not set'
	exit 1
fi

link() {
	if [[ -e "$2" && ! -L "$2" ]]; then
		echo >&2 "[ ${colors[red]}FAIL${colors[nc]} ] $2: file exists and it's a real file."
		return 1
	fi
	ln -sfn "$1" "$2"
	echo "[ ${colors[green]}OK${colors[nc]} ] ${2/$HOME/\~} ${colors[white]}->${colors[nc]} ${1/$HOME/\~}"
}

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"


if [[ "$*" =~ -x($| ) || -n "$all" ]]; then
	link "$dotdir/x/xinitrc" "$HOME/.xinitrc"
	link "$dotdir/x/Xmodmap" "$HOME/.Xmodmap"
	link "$dotdir/x/Xresources" "$HOME/.Xresources"
	link "$dotdir/x/Xresources.d" "$HOME/.Xresources.d"
fi

if [[ "$*" =~ -redshift($| ) || -n "$all" ]]; then
	link "$dotdir/redshift" "$XDG_CONFIG_HOME/redshift"
fi

if [[ "$*" =~ -fontconfig($| ) || -n "$all" ]]; then
	link "$dotdir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
fi

if [[ "$*" =~ -rofi($| ) || -n "$all" ]]; then
	link "$dotdir/rofi" "$XDG_CONFIG_HOME/rofi"
fi

if [[ "$*" =~ -compton($| ) || -n "$all" ]]; then
	link "$dotdir/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
fi

if [[ "$*" =~ -i3($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_DATA_HOME/i3"
	link "$dotdir/i3" "$XDG_CONFIG_HOME/i3"
fi

if [[ "$*" =~ -polybar($| ) || -n "$all" ]]; then
	link "$dotdir/polybar" "$XDG_CONFIG_HOME/polybar"
fi

if [[ "$*" =~ -termite($| ) || -n "$all" ]]; then
	link "$dotdir/termite" "$XDG_CONFIG_HOME/termite"
fi

if [[ "$*" =~ -urxvt($| ) || -n "$all" ]]; then
	link "$dotdir/urxvt" "$HOME/.urxvt"
fi

if [[ "$*" =~ -vim($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_DATA_HOME/vim"
	mkdir -p "$XDG_CACHE_HOME/vim/undofiles"
	link "$dotdir/vim" "$XDG_CONFIG_HOME/vim"
fi

if [[ "$*" =~ -zsh($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_DATA_HOME/zsh"
	mkdir -p "$XDG_DATA_HOME/zsh/ext"
	link "$dotdir/zsh" "$XDG_CONFIG_HOME/zsh"
	link "$dotdir/zsh/.zshenv" "$HOME/.zshenv"
	link "$dotdir/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
fi

if [[ "$*" =~ -bash($| ) || -n "$all" ]]; then
	link "$dotdir/bash/.bashrc" "$HOME/.bashrc"
	link "$dotdir/bash/.bash_profile" "$HOME/.bash_profile"
fi

if [[ "$*" =~ -tmux($| ) || -n "$all" ]]; then
	link "$dotdir/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

if [[ "$*" =~ -git($| ) || -n "$all" ]]; then
	link "$dotdir/git" "$XDG_CONFIG_HOME/git"
fi

if [[ "$*" =~ -ctags($| ) || -n "$all" ]]; then
	link "$dotdir/ctags/ctags" "$HOME/.ctags"
fi

if [[ "$*" =~ -elixir($| ) || -n "$all" ]]; then
	link "$dotdir/elixir/iex.exs" "$HOME/.iex.exs"
fi

if [[ "$*" =~ -gtk($| ) || -n "$all" ]]; then
	link "$dotdir/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
	link "$dotdir/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
fi

if [[ "$*" =~ -dunst($| ) || -n "$all" ]]; then
	link "$dotdir/dunst" "$XDG_CONFIG_HOME/dunst"
fi

if [[ "$*" =~ -mpd($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_DATA_HOME/mpd"
	mkdir -p "$XDG_DATA_HOME/mpd/playlists"
	link "$dotdir/mpd" "$XDG_CONFIG_HOME/mpd"
fi

if [[ "$*" =~ -ncmpcpp($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
	link "$dotdir/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
	link "$dotdir/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
fi

if [[ "$*" =~ -zathura($| ) || -n "$all" ]]; then
	link "$dotdir/zathura" "$XDG_CONFIG_HOME/zathura"
fi

if [[ "$*" =~ -cmus($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/cmus"
	link "$dotdir/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
	link "$dotdir/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
fi

if [[ "$*" =~ -mpv($| ) || -n "$all" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/mpv"
	link "$dotdir/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
	link "$dotdir/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
	link "$dotdir/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
fi
