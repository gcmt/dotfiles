export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_DIRS=$HOME/.local/share/:/usr/local/share/:/usr/share/

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZDATADIR="$XDG_DATA_HOME/zsh"

export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

export MANPAGER="/bin/bash -c \
  \"vim -M -c 'setl ft=man ts=8 nolist nonu' -c 'nn <silent> <buffer> q :q<cr>' \
  < /dev/tty <(col -b)\""

export EDITOR=vim
export BROWSER=firefox
export LANG=en_US.UTF-8
