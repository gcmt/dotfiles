export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_DIRS=$HOME/.local/share/:/usr/local/share/:/usr/share/

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZDATADIR="$XDG_DATA_HOME/zsh"

export GOPATH="$HOME/.local/go"

export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

export MANROFFOPT=-c  # fixes bold styling when viewing manpages in vim
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'setl noma ft=man ts=8 nolist nonu nomod' -c 'nn <silent> <buffer> q :q<cr>' -\""

export EDITOR=vim
export BROWSER=firefox
export LANG=en_US.UTF-8

export RANGER_LOAD_DEFAULT_RC=FALSE

export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
