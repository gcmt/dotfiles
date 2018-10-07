#!/bin/bash

declare -A colors
colors[nc]=$(tput sgr0)
colors[red]=$(tput setaf 1)
colors[green]=$(tput setaf 2)
colors[yellow]=$(tput setaf 3)
colors[white]=$(tput setaf 7)

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
	echo "[ ${colors[green]}OK${colors[nc]} ] ${2/$HOME/\~} -> ${1/$HOME/\~}"
}

skip() {
	echo "[ ${colors[yellow]}SKIP${colors[nc]} ] $1: not installed"
}

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"

all=
if [[ "$*" =~ -all($| ) ]]; then
	all=yes
fi

if [[ "$*" =~ -x($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash xinit 2>/dev/null; then
		skip x
	else
		link "$dotdir/x/xinitrc" "$HOME/.xinitrc"
		link "$dotdir/x/Xmodmap" "$HOME/.Xmodmap"
		link "$dotdir/x/Xresources" "$HOME/.Xresources"
		link "$dotdir/x/Xresources.d" "$HOME/.Xresources.d"
	fi
fi

if [[ "$*" =~ -redshift($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash redshift 2>/dev/null; then
		skip redshift
	else
		link "$dotdir/redshift" "$XDG_CONFIG_HOME/redshift"
	fi
fi

if [[ "$*" =~ -fontconfig($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash fc-list 2>/dev/null; then
		skip fontconfig
	else
		link "$dotdir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
	fi
fi

if [[ "$*" =~ -ranger($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash ranger 2>/dev/null; then
		skip ranger
	else
		link "$dotdir/ranger" "$XDG_CONFIG_HOME/ranger"
	fi
fi

if [[ "$*" =~ -rofi($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash rofi 2>/dev/null; then
		skip rofi
	else
		link "$dotdir/rofi" "$XDG_CONFIG_HOME/rofi"
	fi
fi

if [[ "$*" =~ -compton($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash compton 2>/dev/null; then
		skip compton
	else
		link "$dotdir/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
	fi
fi

if [[ "$*" =~ -i3($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash i3 2>/dev/null; then
		skip i3wm
	else
		mkdir -p "$XDG_DATA_HOME/i3"
		link "$dotdir/i3" "$XDG_CONFIG_HOME/i3"
	fi
fi

if [[ "$*" =~ -polybar($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash polybar 2>/dev/null; then
		skip polybar
	else
		link "$dotdir/polybar" "$XDG_CONFIG_HOME/polybar"
	fi
fi

if [[ "$*" =~ -urxvt($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash urxvt 2>/dev/null; then
		skip urxvt
	else
		link "$dotdir/urxvt" "$HOME/.urxvt"
	fi
fi

if [[ "$*" =~ -vim($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash vim 2>/dev/null; then
		skip vim
	else
		mkdir -p "$XDG_DATA_HOME/vim"
		mkdir -p "$XDG_CACHE_HOME/vim/undo"
		link "$dotdir/vim" "$XDG_CONFIG_HOME/vim"
	fi
fi

if [[ "$*" =~ -zsh($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash zsh 2>/dev/null; then
		skip zsh
	else
		mkdir -p "$XDG_DATA_HOME/zsh"
		mkdir -p "$XDG_DATA_HOME/zsh/ext"
		link "$dotdir/zsh" "$XDG_CONFIG_HOME/zsh"
		link "$dotdir/zsh/.zshenv" "$HOME/.zshenv"
		link "$dotdir/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
	fi
fi

if [[ "$*" =~ -bash($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash bash 2>/dev/null; then
		skip bash
	else
		link "$dotdir/bash/.bashrc" "$HOME/.bashrc"
		link "$dotdir/bash/.bash_profile" "$HOME/.bash_profile"
	fi
fi

if [[ "$*" =~ -tmux($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash tmux 2>/dev/null; then
		skip tmux
	else
		link "$dotdir/tmux/tmux.conf" "$HOME/.tmux.conf"
	fi
fi

if [[ "$*" =~ -git($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash git 2>/dev/null; then
		skip git
	else
		link "$dotdir/git" "$XDG_CONFIG_HOME/git"
	fi
fi

if [[ "$*" =~ -ctags($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash ctags 2>/dev/null; then
		skip ctags
	else
		link "$dotdir/ctags/ctags" "$HOME/.ctags"
	fi
fi

if [[ "$*" =~ -elixir($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash elixir 2>/dev/null; then
		skip elixir
	else
		link "$dotdir/elixir/iex.exs" "$HOME/.iex.exs"
	fi
fi

if [[ "$*" =~ -gtk($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash gtk-demo 2>/dev/null; then
		skip
	else
		link "$dotdir/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
		link "$dotdir/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
	fi
fi

if [[ "$*" =~ -dunst($| ) || -n "$all" ]]; then
	if hash dunst 2>/dev/null; then
		link "$dotdir/dunst" "$XDG_CONFIG_HOME/dunst"
	else
		skip dunst
	fi
fi

if [[ "$*" =~ -mpd($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash mpd 2>/dev/null; then
		skip mpd
	else
		mkdir -p "$XDG_DATA_HOME/mpd"
		mkdir -p "$XDG_DATA_HOME/mpd/playlists"
		link "$dotdir/mpd" "$XDG_CONFIG_HOME/mpd"
	fi
fi

if [[ "$*" =~ -ncmpcpp($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash ncmpcpp 2>/dev/null; then
		skip ncmpcpp
	else
		mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
		link "$dotdir/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
		link "$dotdir/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
	fi
fi

if [[ "$*" =~ -zathura($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash zathura 2>/dev/null; then
		skip zathura
	else
		link "$dotdir/zathura" "$XDG_CONFIG_HOME/zathura"
	fi
fi

if [[ "$*" =~ -cmus($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash cmus 2>/dev/null; then
		skip cmus
	else
		mkdir -p "$XDG_CONFIG_HOME/cmus"
		link "$dotdir/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
		link "$dotdir/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
	fi
fi

if [[ "$*" =~ -mpv($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash mpv 2>/dev/null; then
		skip mpv
	else
		mkdir -p "$XDG_CONFIG_HOME/mpv"
		link "$dotdir/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
		link "$dotdir/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
		link "$dotdir/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
	fi
fi

if [[ "$*" =~ -nemo($| ) || -n "$all" ]]; then
	if [[ -n "$all" ]] && ! hash nemo 2>/dev/null; then
		skip nemo
	else
		link "$dotdir/nemo" "$XDG_DATA_HOME/nemo"
	fi
fi
