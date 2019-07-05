#!/bin/bash

_red() { echo "$(tput setaf 1)$*$(tput sgr0)"; }
_green() { echo "$(tput setaf 2)$*$(tput sgr0)"; }
_yellow() { echo "$(tput setaf 3)$*$(tput sgr0)"; }

dotdir="$(cd "$(dirname "$0")" && pwd)"
args="$(IFS=$'\n'; echo "$*")"

link() {
	if [[ -e "$2" && ! -L "$2" ]]; then
		echo >&2 "[ $(_red FAIL) ] $2: file exists and it's a real file."
		return 1
	fi
	ln -sfn "$1" "$2"
	echo "[ $(_green OK) ] ${2/$HOME/\~} → ${1/$HOME/\~}"
}

skip() {
	echo "[ $(_yellow SKIP) ] $1: not installed"
}

arg() {
	echo "$args" | grep -Fxq -- "$1"
}

installed() {
	hash "$1" 2>/dev/null
}


source "$dotdir/zsh/.zshenv"

if [[ -z "$XDG_CONFIG_HOME" || -z "$XDG_CACHE_HOME" || -z "$XDG_DATA_HOME" ]]; then
	echo 'XDG directories not set' >&2
	exit 1
fi

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"


if arg -x || arg -all; then
	if arg -all && ! arg -x && ! installed xinit; then
		skip x
	else
		link "$dotdir/x/xinitrc" "$HOME/.xinitrc"
		link "$dotdir/x/Xmodmap" "$HOME/.Xmodmap"
		link "$dotdir/x/Xresources" "$HOME/.Xresources"
		link "$dotdir/x/Xresources.d" "$HOME/.Xresources.d"
	fi
fi

if arg -redshift || arg -all; then
	if arg -all && ! arg -redshift && ! installed redshift; then
		skip redshift
	else
		link "$dotdir/redshift" "$XDG_CONFIG_HOME/redshift"
	fi
fi

if arg -fontconfig || arg -all; then
	if arg -all && ! arg -fontconfig && ! installed fc-list; then
		skip fontconfig
	else
		link "$dotdir/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
	fi
fi

if arg -ranger || arg -all; then
	if arg -all && ! arg -ranger && ! installed ranger; then
		skip ranger
	else
		link "$dotdir/ranger" "$XDG_CONFIG_HOME/ranger"
	fi
fi

if arg -rofi || arg -all; then
	if arg -all && ! arg -rofi && ! installed rofi; then
		skip rofi
	else
		link "$dotdir/rofi" "$XDG_CONFIG_HOME/rofi"
	fi
fi

if arg -compton || arg -all; then
	if arg -all && ! arg -compton && ! installed compton; then
		skip compton
	else
		link "$dotdir/compton" "$XDG_CONFIG_HOME/compton"
		link "$XDG_CONFIG_HOME/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
	fi
fi

if arg -i3 || arg -all; then
	if arg -all && ! arg -i3 && ! installed i3; then
		skip i3wm
	else
		mkdir -p "$XDG_DATA_HOME/i3"
		link "$dotdir/i3" "$XDG_CONFIG_HOME/i3"
	fi
fi

if arg -polybar || arg -all; then
	if arg -all && ! arg -polybar && ! installed polybar; then
		skip polybar
	else
		link "$dotdir/polybar" "$XDG_CONFIG_HOME/polybar"
	fi
fi

if arg -urxvt || arg -all; then
	if arg -all && ! arg -urxvt && ! installed urxvt; then
		skip urxvt
	else
		link "$dotdir/urxvt" "$HOME/.urxvt"
	fi
fi

if arg -alacritty || arg -all; then
	if arg -all && ! arg -alacritty && ! installed urxvt; then
		skip alacritty
	else
		link "$dotdir/alacritty" "$XDG_CONFIG_HOME/alacritty"
	fi
fi

if arg -vim || arg -all; then
	if arg -all && ! arg -vim && ! installed vim; then
		skip vim
	else
		mkdir -p "$XDG_DATA_HOME/vim"
		mkdir -p "$XDG_CACHE_HOME/vim/undo"
		link "$dotdir/vim" "$XDG_CONFIG_HOME/vim"
	fi
fi

if arg -zsh || arg -all; then
	if arg -all && ! arg -zsh && ! installed zsh; then
		skip zsh
	else
		mkdir -p "$XDG_DATA_HOME/zsh"
		mkdir -p "$XDG_DATA_HOME/zsh/ext"
		link "$dotdir/zsh" "$XDG_CONFIG_HOME/zsh"
		link "$dotdir/zsh/.zshenv" "$HOME/.zshenv"
		link "$dotdir/zsh/ext/rofi.zsh" "$XDG_DATA_HOME/zsh/ext/rofi.zsh"
	fi
fi

if arg -bash || arg -all; then
	if arg -all && ! arg -bash && ! installed bash; then
		skip bash
	else
		link "$dotdir/bash/.bashrc" "$HOME/.bashrc"
		link "$dotdir/bash/.bash_profile" "$HOME/.bash_profile"
	fi
fi

if arg -tmux || arg -all; then
	if arg -all && ! arg -tmux && ! installed tmux; then
		skip tmux
	else
		link "$dotdir/tmux/tmux.conf" "$HOME/.tmux.conf"
	fi
fi

if arg -git || arg -all; then
	if arg -all && ! arg -git && ! installed git; then
		skip git
	else
		link "$dotdir/git" "$XDG_CONFIG_HOME/git"
	fi
fi

if arg -ctags || arg -all; then
	if arg -all && ! arg -ctags && ! installed ctags; then
		skip ctags
	else
		link "$dotdir/ctags/ctags" "$HOME/.ctags"
	fi
fi

if arg -elixir || arg -all; then
	if arg -all && ! arg -elixir && ! installed elixir; then
		skip elixir
	else
		link "$dotdir/elixir/iex.exs" "$HOME/.iex.exs"
	fi
fi

if arg -gtk || arg -all; then
	if arg -all && ! arg -gtk && ! installed gtk-demo; then
		skip gtk
	else
		link "$dotdir/gtk-2.0" "$XDG_CONFIG_HOME/gtk-2.0"
		link "$dotdir/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
	fi
fi

if arg -dunst || arg -all; then
	if arg -all && ! arg -dunst && ! installed dunst; then
		skip dunst
	else
		link "$dotdir/dunst" "$XDG_CONFIG_HOME/dunst"
	fi
fi

if arg -mpd || arg -all; then
	if arg -all && ! arg -mpd && ! installed mpd; then
		skip mpd
	else
		mkdir -p "$XDG_DATA_HOME/mpd"
		mkdir -p "$XDG_DATA_HOME/mpd/playlists"
		link "$dotdir/mpd" "$XDG_CONFIG_HOME/mpd"
	fi
fi

if arg -ncmpcpp || arg -all; then
	if arg -all && ! arg -ncmpcpp && ! installed ncmpcpp; then
		skip ncmpcpp
	else
		mkdir -p "$XDG_CONFIG_HOME/ncmpcpp"
		link "$dotdir/ncmpcpp/config" "$XDG_CONFIG_HOME/ncmpcpp/config"
		link "$dotdir/ncmpcpp/bindings" "$XDG_CONFIG_HOME/ncmpcpp/bindings"
	fi
fi

if arg -zathura || arg -all; then
	if arg -all && ! arg -zathura && ! installed zathura; then
		skip zathura
	else
		link "$dotdir/zathura" "$XDG_CONFIG_HOME/zathura"
	fi
fi

if arg -cmus || arg -all; then
	if arg -all && ! arg -cmus && ! installed cmus; then
		skip cmus
	else
		mkdir -p "$XDG_CONFIG_HOME/cmus"
		link "$dotdir/cmus/rc" "$XDG_CONFIG_HOME/cmus/rc"
		link "$dotdir/cmus/dark.theme" "$XDG_CONFIG_HOME/cmus/dark.theme"
	fi
fi

if arg -mpv || arg -all; then
	if arg -all && ! arg -mpv && ! installed mpv; then
		skip mpv
	else
		mkdir -p "$XDG_CONFIG_HOME/mpv"
		link "$dotdir/mpv/mpv.conf" "$XDG_CONFIG_HOME/mpv/mpv.conf"
		link "$dotdir/mpv/input.conf" "$XDG_CONFIG_HOME/mpv/input.conf"
		link "$dotdir/mpv/lua-settings" "$XDG_CONFIG_HOME/mpv/lua-settings"
	fi
fi

if arg -nemo || arg -all; then
	if arg -all && ! arg -nemo && ! installed nemo; then
		skip nemo
	else
		link "$dotdir/nemo" "$XDG_DATA_HOME/nemo"
	fi
fi

if arg -sxiv || arg -all; then
	if arg -all && ! arg -sxiv && ! installed sxiv; then
		skip sxiv
	else
		link "$dotdir/sxiv" "$XDG_CONFIG_HOME/sxiv"
	fi
fi
