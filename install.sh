#!/bin/bash

dotdir="$(cd "$(dirname "$0")" && pwd)"
args="$(IFS=$'\n'; echo "$*")"

_red() { echo "$(tput setaf 1)$*$(tput sgr0)"; }
_green() { echo "$(tput setaf 2)$*$(tput sgr0)"; }
_yellow() { echo "$(tput setaf 3)$*$(tput sgr0)"; }

link() {
	if [[ -e "$2" && ! -L "$2" ]]; then
		echo >&2 "[ $(_red FAIL) ] $2: file exists and it's a real file."
		return 1
	fi
	ln -sfn "$1" "$2"
	echo "[ $(_green OK) ] ${2/$HOME/\~} → ${1/$HOME/\~}"
}

_is_arg() {
	echo "$args" | grep -Fxq -- "$1"
}

_installed() {
	if [[ -z "$1" || "$1" == "!" ]]; then
		return 0
	fi
	hash "$1" 2>/dev/null
}

_should_install() {
	local target="$1"
	local required="${2:-$1}"
	if _is_arg "$target" || _is_arg -all; then
		if _is_arg -all && ! _is_arg "$target" && ! _installed "$required"; then
			echo "[ SKIP ] $1: skipped"
			return 1
		else
			return 0
		fi
	fi
	return 1
}

source "$dotdir/zsh/.zshenv"

if [[ -z "$XDG_CONFIG_HOME" || -z "$XDG_CACHE_HOME" || -z "$XDG_DATA_HOME" ]]; then
	echo 'XDG directories not set' >&2
	exit 1
fi

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"

if _should_install x xinit; then
	link "$dotdir/x/xinitrc" "$HOME/.xinitrc"
	link "$dotdir/x/Xmodmap" "$HOME/.Xmodmap"
	link "$dotdir/x/Xresources" "$HOME/.Xresources"
	link "$dotdir/x/Xresources.d" "$HOME/.Xresources.d"
fi

if _should_install redshift; then
	link "$dotdir/redshift" "$XDG_CONFIG_HOME/redshift"
fi

if _should_install fontconfig fc-list; then
	link "$dotdir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
fi

if _should_install ranger; then
	link "$dotdir/ranger" "$XDG_CONFIG_HOME/ranger"
fi

if _should_install vifm; then
	link "$dotdir/vifm" "$XDG_CONFIG_HOME/vifm"
fi

if _should_install rofi; then
	link "$dotdir/rofi" "$XDG_CONFIG_HOME/rofi"
fi

if _should_install compton; then
	link "$dotdir/compton" "$XDG_CONFIG_HOME/picom"
	link "$XDG_CONFIG_HOME/compton/compton.conf" "$XDG_CONFIG_HOME/picom.conf"
fi

if _should_install i3; then
	mkdir -p "$XDG_DATA_HOME/i3"
	link "$dotdir/i3" "$XDG_CONFIG_HOME/i3"
fi

if _should_install polybar; then
	link "$dotdir/polybar" "$XDG_CONFIG_HOME/polybar"
fi

if _should_install urxvt; then
	link "$dotdir/urxvt" "$HOME/.urxvt"
fi

if _should_install vim; then
	link "$dotdir/nvim" "$XDG_CONFIG_HOME/nvim"
fi

if _should_install zsh; then
	mkdir -p "$XDG_DATA_HOME/zsh"
	mkdir -p "$XDG_DATA_HOME/zsh/ext"
	link "$dotdir/zsh" "$XDG_CONFIG_HOME/zsh"
	link "$dotdir/zsh/.zshenv" "$HOME/.zshenv"
	link "$dotdir/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
fi

if _should_install bash; then
	link "$dotdir/bash/.bashrc" "$HOME/.bashrc"
	link "$dotdir/bash/.bash_profile" "$HOME/.bash_profile"
fi

if _should_install tmux; then
	link "$dotdir/tmux" "$XDG_CONFIG_HOME/tmux"
fi

if _should_install git; then
	link "$dotdir/git" "$XDG_CONFIG_HOME/git"
fi

if _should_install ctags; then
	link "$dotdir/ctags/ctags" "$HOME/.ctags"
fi

if _should_install elixir; then
	link "$dotdir/elixir/iex.exs" "$HOME/.iex.exs"
fi

if _should_install gtk gtk-demo; then
	link "$dotdir/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
	link "$dotdir/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
fi

if _should_install dunst; then
	link "$dotdir/dunst" "$XDG_CONFIG_HOME/dunst"
fi

if _should_install mpd; then
	mkdir -p "$XDG_DATA_HOME/mpd"
	mkdir -p "$XDG_DATA_HOME/mpd/playlists"
	link "$dotdir/mpd" "$XDG_CONFIG_HOME/mpd"
fi

if _should_install ncmpcpp; then
	mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
	link "$dotdir/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
	link "$dotdir/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
fi

if _should_install zathura; then
	link "$dotdir/zathura" "$XDG_CONFIG_HOME/zathura"
fi

if _should_install cmus; then
	mkdir -p "$XDG_CONFIG_HOME/cmus"
	link "$dotdir/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
	link "$dotdir/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
fi

if _should_install mpv; then
	mkdir -p "$XDG_CONFIG_HOME/mpv"
	link "$dotdir/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
	link "$dotdir/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
	link "$dotdir/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
fi

if _should_install nemo; then
	link "$dotdir/nemo" "$XDG_DATA_HOME/nemo"
fi

if _should_install sxiv; then
	link "$dotdir/sxiv" "$XDG_CONFIG_HOME/sxiv"
fi

if _should_install imwheel; then
	link "$dotdir/imwheel/imwheelrc" "$HOME/.imwheelrc"
	link "$dotdir/imwheel" "$XDG_CONFIG_HOME/imwheel"
fi

if _should_install ledger; then
	link "$dotdir/ledger/ledgerrc" "$HOME/.ledgerrc"
fi
