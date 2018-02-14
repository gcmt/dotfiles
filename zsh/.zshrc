
# PATHS
# ----------------------------------------------------------------------------

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=$HOME/.local/bin:$PATH

if [[ $OSTYPE == darwin* ]]; then
	export PATH=/usr/local/opt/python/libexec/bin:$PATH
	export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
	export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
	export PATH=/usr/local/opt/findutils/libexec/gnubin:$PATH
	export MANPATH=/usr/local/opt/findutils/libexec/gnuman:$MANPATH
	export PATH=$HOME/.go/bin:$PATH
fi

# EXPORTS
# ----------------------------------------------------------------------------

# use vim for viewing man pages
export MANPAGER="/bin/bash -c \
	\"vim -M -c 'setl ft=man ts=8 nolist nonu' -c 'nn <buffer> q :q<cr>' \
	< /dev/tty <(col -b)\""

export EDITOR=vim

export VIRTUAL_ENV_DISABLE_PROMPT=1

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# OPTIONS
# ----------------------------------------------------------------------------

KEYTIMEOUT=1
PROMPT_EOL_MARK=""
WORDCHARS=${WORDCHARS/\//}
DIRSTACKSIZE=5
HISTSIZE=4096
SAVEHIST=4096
HISTFILE="$XDG_DATA_HOME/zsh/history"

setopt auto_cd
setopt extended_glob
setopt no_list_ambiguous
setopt transient_rprompt
setopt complete_aliases

setopt share_history
setopt extended_history
setopt append_history
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks

setopt no_beep
setopt no_listbeep
setopt no_histbeep

setopt pushd_minus
setopt pushd_ignore_dups
setopt auto_pushd
setopt pushd_silent

# enable commands editing
autoload -U edit-command-line
zle -N edit-command-line

# enable completions
autoload -U compinit
compinit

zstyle ':completion:*' matcher-list '' 'r:|?=** m:{a-z\-}={A-Z\_}'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 3
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' format '-- %d'
zstyle ':completion:*:messages' format '-- %d'
zstyle ':completion:*:descriptions' format '-- %d'
zstyle ':completion:*:corrections' format '-- %d (errors %e)'
zstyle ':completion:*:warnings' format '-- no match for: %d'

# ignore EOF in tmux
[ -n "$TMUX" ] && setopt ignoreeof

# allow ctrl-s and ctrl-q bindings to be used
stty -ixon

# FUNCTIONS
# ----------------------------------------------------------------------------

function lb() {
	local name=${1:-$(date '+%Y-%m-%d')}
	vim ~/Documents/logbook/$name.md
}

# create virtual environment
mkvenv() {
	local venv=${1:-venv}
	if [ -d "$venv" -o -f "$venv" ]; then
		echo >&2 "mkvenv: file '$venv' already exists"
		return 1
	fi
	python3 -m venv "$venv"
	source "$venv/bin/activate"
}

# activate virtual environment
activate() {
	local venv=${1:-venv}
	if [ ! -f "$venv/bin/activate" ]; then
		venv="$HOME/.virtualenvs/$venv"
	fi
	if [ ! -f "$venv/bin/activate" ]; then
		echo >&2 "activate: virtual environment doesn't exist"
		return 1
	fi
	source "$venv/bin/activate"
	echo "virtual environment activated: $venv"
}

# search and open files with vim
vimf() {
	local f=$(mktemp -d)/flist
	rg --files -g "!node_modules/*" -g "!venv/*" -g "!dist/*" -g "!build/*" \
		-g "!*.pyc" -g "!*.beam" -g "!*.pdf" -g "!*.jpg" -g "!*.png" -g "!*.gif" -g "!*.mp4" -g "!*.gpg" \
		| grep "$(echo "$@" | sed 's/\s\+/.*/')" > "$f"
	if [ -s "$f" ]; then
		vim -c "setl bt=nofile noma" -c "argd %" "$f" \
			-c "nn <silent> <buffer> gf ^vg_gf" -c "nmap <buffer> l gf" \
			-c "nn <silent> <buffer> gF :set bh=wipe<bar>norm gf<cr>" -c "nmap <buffer> L gF"
	else
		echo -n "$0: nothing found"
	fi
}

# set/unset workspace (see _prompt_cwd function)
setw() {
	if [ $# -eq 0 ]; then
		WORKSPACE=
	else
		WORKSPACE="$(realpath $1)"
	fi
}

# git shortcut
g() {
	if [ $# -eq 0 ]; then
		git status
	else
		git "$@"
	fi
}

compdef g=git

# vagrant shortcut
va() {
	if [ $# -eq 0 ]; then
		vagrant status
	else
		vagrant "$@"
	fi
}

# create directory and move into it
mcd() {
	mkdir -p "$@" && cd "$@"
}

compdef mcd=mkdir

# ALIASES
# ----------------------------------------------------------------------------

alias ze='vim $XDG_CONFIG_HOME/zsh/.zshrc'
alias zs='source $XDG_CONFIG_HOME/zsh/.zshrc'

alias cb='cd -'

alias ..=' ..'
alias ...=' ../..'
alias ....=' ../../..'

alias rm=' rm -Iv'
alias mv=' mv -iv'
alias cp=' cp -iv'
alias mkdir='mkdir -pv'

alias ll='ls -lhp'
alias lla='ls -lhAp'
alias lld='ls -lhA | grep "^d"'
alias llf='ls -lhA | grep -v "^d"'

alias py="python"
alias ipy="ipython"
alias pudb="cursor -cmd; pudb3"
alias pypath='python -c "import sys; [print(p) for p in filter(None, sys.path)]"'

alias open='xdg-open'
alias rg="rg --color=never -S"
alias http="http --style=algol"

alias rgf='rg --files -g "!node_modules/*" -g "!venv/*" | rg'
alias rgfa='rg --files --hidden -g "!node_modules/*" -g "!venv/*" -g "!.git/*" | rg'

# CURSOR
# ----------------------------------------------------------------------------

if [ -n "$ITERM_PROFILE" ]; then
	# 0 -> block
	# 1 -> bar
	cursor_cmd="\e]50;CursorShape=0\007"
	cursor_ins="\e]50;CursorShape=1\007"
fi

if [ -n "$VTE_VERSION" ]; then
	# 0 -> blinking block
	# 1 -> blinking block
	# 2 -> steady block
	# 3 -> blinking underline
	# 4 -> steady underline
	# 5 -> blinking bar
	# 6 -> steady bar
	cursor_cmd="\e[2 q"
	cursor_ins="\e[6 q"
fi

if [ -n "$TMUX" ]; then
	cursor_cmd="\ePtmux;\e$cursor_cmd\e\\"
	cursor_ins="\ePtmux;\e$cursor_ins\e\\"
fi

zle-line-init() {
	print -n $cursor_ins
}

zle-keymap-select() {
	case $KEYMAP in
		vicmd) print -n $cursor_cmd;;
		*) print -n $cursor_ins;;
	esac
	zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# PROMPT
# ----------------------------------------------------------------------------

autoload -U colors
colors

setopt prompt_subst

precmd() {
	if [[ $TERM == *xterm* ]]; then
		print -nP "\e]2;$HOME - Termite\a"
	fi
}

_prompt_git_branch() {
	local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
	if [ $? -ne 0 ] || [ -z "$branch" ]; then
		return
	fi
	git diff --quiet --ignore-submodules HEAD &> /dev/null
	if [ $? -eq 1 ]; then
		echo -n " ~$branch*"
	else
		echo -n " ~$branch"
	fi
}

_prompt_venv() {
	[ $VIRTUAL_ENV ] && echo " ($(basename $VIRTUAL_ENV))"
}

_prompt_cwd() {
	if [ -z "$WORKSPACE" ]; then
		echo -n "%F{15}${PWD/$HOME/~}%f"
	else
		echo -n "%F{15}${PWD/$WORKSPACE/..}%f"
	fi
}

_prompt_ww() {
	echo -n "%F{15}$(whoami)@$(hostname)%f${sep}"
}

_prompt_exit_code() {
	local code=$?
	[ $code -ne 0 ] && echo "%F{red}${code}%f${sep}"
}

# ›
sep=' '
PROMPT='$(_prompt_exit_code)$(_prompt_ww)$(_prompt_cwd) %F{15}%(!.#.$)%f '
RPROMPT='$(_prompt_git_branch)$(_prompt_venv)'

# OPTIONAL
# ----------------------------------------------------------------------------

if hash rofi 2>/dev/null; then
	source "$ZDOTDIR/rofi.zsh"
fi

if [ -f "$XDG_DATA_HOME/zsh/opt/z/z.sh" ]; then
	export _Z_DATA="$XDG_DATA_HOME/z/database"
	source "$XDG_DATA_HOME/zsh/opt/z/z.sh"
fi

if [ -f "$XDG_DATA_HOME/zsh/opt/zsh-autosuggestions/zsh-autosuggestions.zsh" -a ! "$TERM" = "linux" ]; then
	source "$XDG_DATA_HOME/zsh/opt/zsh-autosuggestions/zsh-autosuggestions.zsh"
	export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=238'
	bindkey '^d' autosuggest-execute
	bindkey '^a' autosuggest-accept
fi

# BINDKEYS
# ----------------------------------------------------------------------------

bindkey -v

toggle-sudo() {
	local pos=$CURSOR
	if [[ "$BUFFER" =~ "^sudo " ]]; then
		BUFFER=$(echo "$BUFFER" | cut -b 6-)
		CURSOR=$(($pos-5))
	else
		BUFFER="sudo $BUFFER"
		CURSOR=$(($pos+5))
	fi
}
zle -N toggle-sudo

bindkey '^s' toggle-sudo

# enter command mode before searching backward
history-search-backward-custom() {
	zle vi-cmd-mode
	zle history-search-backward
}
zle -N history-search-backward-custom

# enter command mode before searching forward
history-search-forward-custom() {
	zle vi-cmd-mode
	zle history-search-forward
}
zle -N history-search-forward-custom

bindkey '^p' history-search-backward-custom
bindkey '^n' history-search-forward-custom

bindkey '^w' backward-delete-word
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

bindkey -s '^z' '^u fg^m'

bindkey -s '^e' '^u ranger^m'

bindkey '^k' edit-command-line
bindkey -M vicmd '^k' edit-command-line

bindkey -M vicmd 'H' vi-beginning-of-line
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'Y' vi-yank-eol

# LOCAL RC
# ----------------------------------------------------------------------------

if [ -f ~/.zshrc.local ]; then
	source ~/.zshrc.local
fi
