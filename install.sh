#!/usr/bin/env bash

DOTDIR="$(cd "$(dirname "$0")" && pwd)"

source "$DOTDIR/zsh/.zshenv"

if [ -z "$XDG_CONFIG_HOME" -o -z "$XDG_CACHE_HOME" -o -z "$XDG_DATA_HOME" ]
then
	echo >&2 'XDG directories not set'
	exit 1
fi

mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"

if [[ "$@" =~ '-x' || "$@" =~ '-all' ]]; then
	if hash xinit 2>/dev/null
	then
		ln -sf "$DOTDIR/X11/xinitrc" "$HOME/.xinitrc"
		echo "[ ok ] xinitrc"
	else
		echo "[ skip ] xinitrc"
	fi
fi

if [[ "$@" =~ '-fontconfig' || "$@" =~ '-all' ]]
then
	if hash fc-list 2>/dev/null
	then
		ln -snf "$DOTDIR/fontconfig" "$XDG_CONFIG_HOME/fontconfig"
		echo "[ ok ] fontconfig"
	else
		echo "[ skip ] fontconfig"
	fi
fi

if [[ "$@" =~ '-rofi' || "$@" =~ '-all' ]]
then
	if hash rofi 2>/dev/null
	then
		ln -snf "$DOTDIR/rofi" "$XDG_CONFIG_HOME/rofi"
		echo "[ ok ] rofi"
	else
		echo "[ skip ] rofi"
	fi
fi

if [[ "$@" =~ '-compton' || "$@" =~ '-all' ]]; then
	if hash compton 2>/dev/null
	then
		ln -sf "$DOTDIR/compton/compton.conf" "$XDG_CONFIG_HOME/compton.conf"
		echo "[ ok ] compton"
	else
		echo "[ skip ] compton"
	fi
fi

if [[ "$@" =~ '-i3' || "$@" =~ '-all' ]]
then
	if hash i3 2>/dev/null
	then
		mkdir -p "$XDG_DATA_HOME/i3"
		ln -snf "$DOTDIR/i3" "$XDG_CONFIG_HOME/i3"
		echo "[ ok ] i3"
	else
		echo "[ skip ] i3"
	fi
fi

if [[ "$@" =~ '-polybar' || "$@" =~ '-all' ]]
then
	if hash polybar 2>/dev/null
	then
		ln -snf "$DOTDIR/polybar" "$XDG_CONFIG_HOME/polybar"
		echo "[ ok ] polybar"
	else
		echo "[ skip ] polybar"
	fi
fi
if [[ "$@" =~ '-rofi' || "$@" =~ '-all' ]]
then
	if hash rofi 2>/dev/null
	then
		ln -snf "$DOTDIR/rofi" "$XDG_CONFIG_HOME/rofi"
		echo "[ ok ] rofi"
	else
		echo "[ skip ] rofi"
	fi
fi

if [[ "$@" =~ '-termite' || "$@" =~ '-all' ]]
then
	if hash termite 2>/dev/null
	then
		ln -snf "$DOTDIR/termite" "$XDG_CONFIG_HOME/termite"
		echo "[ ok ] termite"
	else
		echo "[ skip ] termite"
	fi
fi

if [[ "$@" =~ '-vim' || "$@" =~ '-all' ]]
then
	if hash vim 2>/dev/null
	then
		mkdir -p "$XDG_DATA_HOME/vim"
		mkdir -p "$XDG_CACHE_HOME/vim/undofiles"
		ln -snf "$DOTDIR/vim" "$XDG_CONFIG_HOME/vim"
		echo "[ ok ] vim"
	else
		echo "[ skip ] vim"
	fi
fi

if [[ "$@" =~ '-zsh' || "$@" =~ '-all' ]]
then
	if hash zsh 2>/dev/null
	then
		mkdir -p "$XDG_DATA_HOME/zsh"
		ln -sf "$DOTDIR/zsh/.zshenv" "$HOME/.zshenv"
		ln -snf "$DOTDIR/zsh" "$XDG_CONFIG_HOME/zsh"
		echo "[ ok ] zsh"
	else
		echo "[ skip ] zsh"
	fi
fi

if [[ "$@" =~ '-tmux' || "$@" =~ '-all' ]]
then
	if hash tmux 2>/dev/null
	then
		ln -sf "$DOTDIR/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux.conf"
		echo "[ ok ] tmux"
	else
		echo "[ skip ] tmux"
	fi
fi

if [[ "$@" =~ '-git' || "$@" =~ '-all' ]]
then
	if hash git 2>/dev/null
	then
		ln -snf "$DOTDIR/git" "$XDG_CONFIG_HOME/git"
		echo "[ ok ] git"
	else
		echo "[ skip ] git"
	fi
fi

if [[ "$@" =~ '-ctags' || "$@" =~ '-all' ]]
then
	if hash ctags 2>/dev/null
	then
		ln -sf "$DOTDIR/ctags/ctags" "$HOME/.ctags"
		echo "[ ok ] ctags"
	else
		echo "[ skip ] ctags"
	fi
fi

if [[ "$@" =~ '-elixir' || "$@" =~ '-all' ]]
then
	if hash iex 2>/dev/null
	then
		ln -sf "$DOTDIR/elixir/iex.exs" "$HOME/.iex.exs"
		echo "[ ok ] iex.exs"
	else
		echo "[ skip ] iex.exs"
	fi
fi

if [[ "$@" =~ '-gtk' || "$@" =~ '-all' ]]
then
	if hash gtk3-demo 2>/dev/null
	then
		ln -snf "$DOTDIR/gtk-3.0" "$XDG_CONFIG_HOME/gtk-3.0"
		echo "[ ok ] gtk3"
	else
		echo "[ skip ] gtk3"
	fi
fi

if [[ "$@" =~ '-dunst' || "$@" =~ '-all' ]]
then
	if hash dunst 2>/dev/null
	then
		ln -snf "$DOTDIR/dunst" "$XDG_CONFIG_HOME/dunst"
		echo "[ ok ] dunst"
	else
		echo "[ skip ] dunst"
	fi
fi

if [[ "$@" =~ '-zathura' || "$@" =~ '-all' ]]
then
	if hash zathura 2>/dev/null
	then
		ln -snf "$DOTDIR/zathura" "$XDG_CONFIG_HOME/zathura"
		echo "[ ok ] zathura"
	else
		echo "[ skip ] zathura"
	fi
fi

unset DOTDIR
