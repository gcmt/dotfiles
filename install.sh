#!/bin/bash

if [[ "$*" =~ -all($| ) ]]; then
	ALL=yes
fi

if [[ "$*" =~ -force($| ) ]]; then
	FORCE=yes
fi

DOTDIR="$(cd "$(dirname "$0")" && pwd)"

source "$DOTDIR/zsh/.zshenv"

if [[ -z "$XDG_CONFIG_HOME" || -z "$XDG_CACHE_HOME" || -z "$XDG_DATA_HOME" ]]; then
	echo >&2 'XDG directories not set'
	exit 1
fi

link() {
	if [[ -e "$2" && ! -L "$2" ]]; then
		if [[ -z "$FORCE" ]]; then
			echo >&2 "$2: file exists and it's a real file. Use -force to override."
			return 1
		fi
	fi
	ln -sfn "$1" "$2"
	echo "$2 -> $1"
}

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"

echo ""

if [[ "$*" =~ -x($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/x/xinitrc" "$HOME/.xinitrc"
	link "$DOTDIR/x/Xmodmap" "$HOME/.Xmodmap"
	link "$DOTDIR/x/Xresources" "$HOME/.Xresources"
	link "$DOTDIR/x/Xresources.d" "$HOME/.Xresources.d"
	echo ""
fi

if [[ "$*" =~ -fontconfig($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
	echo ""
fi

if [[ "$*" =~ -rofi($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/rofi" "$XDG_CONFIG_HOME/rofi"
	echo ""
fi

if [[ "$*" =~ -compton($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
	echo ""
fi

if [[ "$*" =~ -i3($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_DATA_HOME/i3"
	link "$DOTDIR/i3" "$XDG_CONFIG_HOME/i3"
	echo ""
fi

if [[ "$*" =~ -polybar($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/polybar" "$XDG_CONFIG_HOME/polybar"
	echo ""
fi

if [[ "$*" =~ -termite($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/termite" "$XDG_CONFIG_HOME/termite"
	echo ""
fi

if [[ "$*" =~ -urxvt($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/urxvt" "$HOME/.urxvt"
	echo ""
fi

if [[ "$*" =~ -vim($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_DATA_HOME/vim"
	mkdir -p "$XDG_CACHE_HOME/vim/undofiles"
	link "$DOTDIR/vim" "$XDG_CONFIG_HOME/vim"
	echo ""
fi

if [[ "$*" =~ -zsh($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_DATA_HOME/zsh"
	mkdir -p "$XDG_DATA_HOME/zsh/ext"
	link "$DOTDIR/zsh" "$XDG_CONFIG_HOME/zsh"
	link "$DOTDIR/zsh/.zshenv" "$HOME/.zshenv"
	link "$DOTDIR/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
	echo ""
fi

if [[ "$*" =~ -bash($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/bash/.bashrc" "$HOME/.bashrc"
	link "$DOTDIR/bash/.bash_profile" "$HOME/.bash_profile"
	echo ""
fi

if [[ "$*" =~ -tmux($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/tmux/tmux.conf" "$HOME/.tmux.conf"
	echo ""
fi

if [[ "$*" =~ -git($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/git" "$XDG_CONFIG_HOME/git"
	echo ""
fi

if [[ "$*" =~ -ctags($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/ctags/ctags" "$HOME/.ctags"
	echo ""
fi

if [[ "$*" =~ -elixir($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/elixir/iex.exs" "$HOME/.iex.exs"
	echo ""
fi

if [[ "$*" =~ -gtk($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
	link "$DOTDIR/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
	echo ""
fi

if [[ "$*" =~ -dunst($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/dunst" "$XDG_CONFIG_HOME/dunst"
	echo ""
fi

if [[ "$*" =~ -mpd($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_DATA_HOME/mpd"
	mkdir -p "$XDG_DATA_HOME/mpd/playlists"
	link "$DOTDIR/mpd" "$XDG_CONFIG_HOME/mpd"
	echo ""
fi

if [[ "$*" =~ -ncmpcpp($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
	link "$DOTDIR/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
	link "$DOTDIR/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
	echo ""
fi

if [[ "$*" =~ -zathura($| ) || -n "$ALL" ]]; then
	link "$DOTDIR/zathura" "$XDG_CONFIG_HOME/zathura"
	echo ""
fi

if [[ "$*" =~ -cmus($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/cmus"
	link "$DOTDIR/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
	link "$DOTDIR/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
	echo ""
fi

if [[ "$*" =~ -mpv($| ) || -n "$ALL" ]]; then
	mkdir -p "$XDG_CONFIG_HOME/mpv"
	link "$DOTDIR/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
	link "$DOTDIR/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
	link "$DOTDIR/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
	echo ""
fi
