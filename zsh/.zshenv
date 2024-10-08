export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_DIRS=$HOME/.local/share/:/usr/local/share/:/usr/share/

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZDATADIR="$XDG_DATA_HOME/zsh"

export GOPATH="$HOME/.local/go"

export MANROFFOPT=-c  # fixes bold styling when viewing manpages in vim
export MANPAGER="/bin/sh -c \"col -b | nvim -c 'setl noma ft=man ts=8 nolist nonu nomod' -c 'nn <silent> <buffer> q :q<cr>' -\""

export EDITOR=nvim
export BROWSER=firefox
export LANG=en_US.UTF-8

export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
