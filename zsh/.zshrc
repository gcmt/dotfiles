
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

export LESSKEY="$XDG_CONFIG_HOME/less/keys"
export LESSHISTFILE="$XDG_DATA_HOME/less/history"

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

# quick file search with ripgrep
rgf() {
	rg --files -g "!node_modules/*" -g "!venv/*" | rg "$@"
}
rgfa() {
	rg --files --hidden -g "!node_modules/*" -g "!venv/*" -g "!.git/*" | rg "$@"
}

# search and open files with vim
vimf() {
	local f=$(mktemp -d)/flist
	rg --files \
		-g "!node_modules/*" -g "!venv/*" -g "!dist/*" -g "!build/*" \
		-g "!*.pyc" -g "!*.beam" -g "!*.pdf" -g "!*.jpg" -g "!*.png" -g "!*.gif" -g "!*.mp4" -g "!*.gpg" \
		| grep "$(echo "$@" | sed 's/\s\+/.*/')" > "$f"
	if [ -s "$f" ]; then
		vim \
			-c "argd %" "$f" \
			-c "setl bt=nofile nomodifiable" \
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

# create directory and move into it
mcd() {
	mkdir -p "$@" && cd "$@"
}
compdef mcd=mkdir

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
alias pudb="pudb3"
alias pypath='python -c "import sys; [print(p) for p in filter(None, sys.path)]"'

alias open='xdg-open'
alias rg="rg --color=never -S"
alias http="http --style=algol"

# VI MODE
# ----------------------------------------------------------------------------

# use different colors for each mode
zle-keymap-select() {
	case $KEYMAP in
		viins|main) zle_highlight=(default:fg=15) ;;
		vicmd) zle_highlight=(default:fg=white) ;;
	esac
	zle reset-prompt
}

zle_highlight=(default:fg=15)
zle -N zle-keymap-select

# HOOKS
# ----------------------------------------------------------------------------

autoload -U add-zsh-hook

set-title() {
	if [[ "$TERM" == *xterm* ]]; then
		print -n "\e]2;$PWD - Terminal\a"
	fi
}
add-zsh-hook precmd set-title

forget-commands() {
	local cmd="${${(z)1}[1]}"
	# forget mistyped commands
	if [[ ! -e "$cmd" ]] && ! hash "$cmd" 2>/dev/null; then
		return 1
	fi
	if [[ "$1" =~ '^(fg|rm|mv|cp|l|la|zs|ze|mcd|mkdir)\>' ]]; then
		return 1
	fi
	if [[ "$1" =~ '^(ll|lla|va|ranger|vim|python|py|ipy|pudb)\s+$' ]]; then
		return 1
	fi
}
add-zsh-hook zshaddhistory forget-commands

# PROMPT
# ----------------------------------------------------------------------------

autoload -U colors
colors

setopt prompt_subst

_prompt_git() {
	local branch
	branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if (( $? != 0 )); then
		return
	fi
	echo -n " ~$branch"
}

_prompt_venv() {
	test -n "$VIRTUAL_ENV" && echo -n "venv"
}

_prompt_user() {
	echo -n "%F{15}$(whoami)@$(hostname)%f"
}

_prompt_cwd() {
	if (( DIRTRIM == 1 )); then
		echo -n "%F{15}%(4~|../%2~|%~)%f"
	else
		echo -n "%F{15}%~%f"
	fi
}

DIRTRIM=1

PROMPT='%F{red}%(?..%? )%f%(1j.%jj .)$(_prompt_user) $(_prompt_cwd) %F{15}$%f '
RPROMPT='$(_prompt_git)$(_prompt_venv)'

# BINDINGS
# ----------------------------------------------------------------------------

bindkey -v

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey '^w' backward-delete-word
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^k' edit-command-line

bindkey -M vicmd '^k' edit-command-line
bindkey -M vicmd 'H' vi-beginning-of-line
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'Y' vi-yank-eol
bindkey '^e' end-of-line

toggle-sudo() {
	local pos=$CURSOR
	if [[ "$BUFFER" =~ "^sudo\>" ]]; then
		BUFFER=$(echo "$BUFFER" | cut -b 6-)
		CURSOR=$(($pos-5))
	else
		BUFFER="sudo $BUFFER"
		CURSOR=$(($pos+5))
	fi
}
zle -N toggle-sudo
bindkey '^s' toggle-sudo
bindkey -M vicmd '^s' toggle-sudo

fix-command() {
	zle vi-first-non-blank
	zle kill-word
	zle vi-insert
}
zle -N fix-command
bindkey '^f' fix-command
bindkey -M vicmd '^f' fix-command

trim-prompt-cwd() {
	DIRTRIM=$((1 - DIRTRIM))
	zle reset-prompt
}
zle -N trim-prompt-cwd
bindkey '^t' trim-prompt-cwd

# cd-back() {
	# popd
	# zle reset-prompt
# }
# zle -N cd-back
# bindkey '^[b' cd-back

# cd-parent() {
	# pushd ..
	# zle reset-prompt
# }
# zle -N cd-parent
# bindkey '^[u' cd-parent

# EXTERNAL
# ----------------------------------------------------------------------------

if [[ -e "$ZDATADIR/ext/rofi.zsh" ]]; then
	source "$ZDATADIR/ext/rofi.zsh"
	# bindkey '^f' rofi-find
	# bindkey '^g' rofi-cd
	# bindkey '^r' rofi-history
fi

	export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=236'
if [[ -e "$ZDATADIR/ext/zsh-autosuggestions/zsh-autosuggestions.zsh" && "$TERM" != "linux" ]]; then
	source "$ZDATADIR/ext/zsh-autosuggestions/zsh-autosuggestions.zsh"
	bindkey '^d' autosuggest-execute
fi

# LOCAL RC
# ----------------------------------------------------------------------------

if [ -f ~/.zshrc.local ]; then
	source ~/.zshrc.local
fi
