#!/usr/bin/env bash

DOTDIR="$(cd "$(dirname "$0")" && pwd)"

source "$DOTDIR/zsh/.zshenv"

if [ -z "$XDG_CONFIG_HOME" -o -z "$XDG_CACHE_HOME" -o -z "$XDG_DATA_HOME" ]; then
	echo >&2 'XDG directories not set'
	exit 1
fi

link() {
	ln -sfn "$1" "$2"
	echo "$2 -> $1"
}

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"

if [[ "$@" =~ '-x' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/x/xinitrc" "$HOME/.xinitrc"
	link "$DOTDIR/x/Xmodmap" "$HOME/.Xmodmap"
	link "$DOTDIR/x/Xresources" "$HOME/.Xresources"
	link "$DOTDIR/x/Xresources.d" "$HOME/.Xresources.d"
fi

if [[ "$@" =~ '-fontconfig' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
fi

if [[ "$@" =~ '-rofi' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/rofi" "$XDG_CONFIG_HOME/rofi"
fi

if [[ "$@" =~ '-compton' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
fi

if [[ "$@" =~ '-i3' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_DATA_HOME/i3"
	link "$DOTDIR/i3" "$XDG_CONFIG_HOME/i3"
fi

if [[ "$@" =~ '-polybar' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/polybar" "$XDG_CONFIG_HOME/polybar"
fi

if [[ "$@" =~ '-termite' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/termite" "$XDG_CONFIG_HOME/termite"
fi

if [[ "$@" =~ '-urxvt' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/urxvt" "$HOME/.urxvt"
fi

if [[ "$@" =~ '-vim' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_DATA_HOME/vim"
	mkdir -p "$XDG_CACHE_HOME/vim/undofiles"
	link "$DOTDIR/vim" "$XDG_CONFIG_HOME/vim"
fi

if [[ "$@" =~ '-zsh' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_DATA_HOME/zsh"
	mkdir -p "$XDG_DATA_HOME/zsh/ext"
	link "$DOTDIR/zsh" "$XDG_CONFIG_HOME/zsh"
	link "$DOTDIR/zsh/.zshenv" "$HOME/.zshenv"
	link "$DOTDIR/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
fi

if [[ "$@" =~ '-bash' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/bash/.bashrc" "$HOME/.bashrc"
	link "$DOTDIR/bash/.bash_profile" "$HOME/.bash_profile"
fi

if [[ "$@" =~ '-tmux' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

if [[ "$@" =~ '-git' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/git" "$XDG_CONFIG_HOME/git"
fi

if [[ "$@" =~ '-ctags' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/ctags/ctags" "$HOME/.ctags"
fi

if [[ "$@" =~ '-elixir' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/elixir/iex.exs" "$HOME/.iex.exs"
fi

if [[ "$@" =~ '-gtk' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
	link "$DOTDIR/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
fi

if [[ "$@" =~ '-dunst' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/dunst" "$XDG_CONFIG_HOME/dunst"
fi

if [[ "$@" =~ '-mpd' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_DATA_HOME/mpd"
	mkdir -p "$XDG_DATA_HOME/mpd/playlists"
	link "$DOTDIR/mpd" "$XDG_CONFIG_HOME/mpd"
fi

if [[ "$@" =~ '-ncmpcpp' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
	link "$DOTDIR/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
	link "$DOTDIR/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
fi

if [[ "$@" =~ '-zathura' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/zathura" "$XDG_CONFIG_HOME/zathura"
fi

if [[ "$@" =~ '-mailcheck' || "$@" =~ '-all' ]]; then
	link "$DOTDIR/mailcheck" "$XDG_DATA_HOME/mailcheck"
fi

if [[ "$@" =~ '-cmus' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_CONFIG_HOME/cmus"
	link "$DOTDIR/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
	link "$DOTDIR/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
fi

if [[ "$@" =~ '-mpv' || "$@" =~ '-all' ]]; then
	mkdir -p "$XDG_CONFIG_HOME/mpv"
	link "$DOTDIR/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
	link "$DOTDIR/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
	link "$DOTDIR/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
fi
