
# EXPORTS
# ----------------------------------------------------------------------------

export BORG_REMOTE_PATH=borg1
export VIRTUAL_ENV_DISABLE_PROMPT=1

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

# HOOKS
# ----------------------------------------------------------------------------

autoload -U add-zsh-hook

set-title() {
	[ -z "$TMUX" ] && print -n "\e]2;$PWD - Terminal\a"
}
add-zsh-hook precmd set-title

forget-commands() {
	local cmd="${${(z)1}[1]}"
	# forget mistyped commands
	if [[ ! -e "$cmd" ]] && ! type "$cmd" >/dev/null 2>&1; then
		return 1
	fi
	if [[ "$1" =~ '^(fg|rm|mv|cp|l|la|zs|ze|youtube-dl)\>' ]]; then
		return 1
	fi
	if [[ "$1" =~ '^(cd|ll|lla|va|vim|python|py|ipy|pudb)\s+$' ]]; then
		return 1
	fi
}
add-zsh-hook zshaddhistory forget-commands

# COLORS
# ----------------------------------------------------------------------------

_colorscheme() {
	xrdb -query all | grep colorscheme | grep -o '\w\+$'
}

set-colors() {
	if [[ ! $DISPLAY ]]; then
		return
	fi
	if [[ "$(_colorscheme)" == "dark" ]]; then
		export LS_COLORS='fi=97'
		export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=237'
	else
		export LS_COLORS='fi=90'
		export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=249'
	fi
}

add-zsh-hook precmd set-colors

# VI MODE
# ----------------------------------------------------------------------------

bindkey -v

# use different colors for each mode
zle-keymap-select() {
	case $KEYMAP in
		viins|main) zle_highlight=(default:fg=magenta) ;;
		vicmd) zle_highlight=(default:fg=22) ;;
	esac
}

zle_highlight=(default:fg=magenta)
zle -N zle-keymap-select

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
	echo -n " git:$branch"
}

_prompt_venv() {
	test -n "$VIRTUAL_ENV" && echo -n "(venv) "
}

_prompt_user() {
	echo -n "%F{18}$(whoami)@$(hostname)%f"
}

_prompt_cwd() {
	if (( DIRTRIM == 1 )); then
		echo -n "%F{18}%(4~|../%2~|%~)%f"
	else
		echo -n "%F{18}%~%f"
	fi
}

DIRTRIM=1

PROMPT='%F{red}%(?..%? )%f%(1j.%jj .)$(_prompt_user) $(_prompt_cwd) $(_prompt_venv)%F{18}$%f '
RPROMPT='$(_prompt_git)'

# FUNCTIONS
# ----------------------------------------------------------------------------

function lb() {
	local name=${1:-$(date '+%Y-%m-%d')}
	vim ~/Documents/logbook/$name.txt
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
		echo >&2 "activate: virtual environment '$venv' doesn't exist"
		return 1
	fi
	source "$venv/bin/activate"
	echo "virtual environment activated: $venv"
}

# open files that contain the given pattern
vimg() {
	vim -q <(rg --vimgrep "$@") +copen
}

# search and open files with vim
vimf() {
	local flist=$(mktemp -d)/filelist
	rg --files \
		-g "!node_modules/*" -g "!venv/*" -g "!dist/*" -g "!build/*" \
		-g "!*.pyc" -g "!*.beam" -g "!*.pdf" -g "!*.jpg" -g "!*.png" -g "!*.gif" -g "!*.mp4" -g "!*.gpg" \
		| grep "$(echo "$@" | sed 's/\s\+/.*/')" > "$flist"
	if [[ -s "$flist" ]]; then
		vim "$flist" \
			-c "argd %" \
			-c "setl nomodifiable" \
			-c "nn <silent> <buffer> gf :set bl<bar>norm! ^vg_gf<cr>" -c "nmap <buffer> l gf" \
			-c "nn <silent> <buffer> gF :set nobl<bar>norm! ^vg_gf<cr>" -c "nmap <buffer> L gF"
	else
		echo -n "$0: nothing found"
	fi
}

# create directory and move into it
mcd() {
	mkdir -p "$@" && cd "$@"
}
compdef mcd=mkdir

# git shortcut
g() {
	[ $# -eq 0 ] && git status || git "$@"
}
compdef g=git

# vagrant shortcut
va() {
	[ $# -eq 0 ] && vagrant status || vagrant "$@"
}

# ALIASES
# ----------------------------------------------------------------------------

alias ze='vim $ZDOTDIR/.zshrc'
alias zs='source $ZDOTDIR/.zshrc'

alias dark='colorscheme dark'
alias light='colorscheme light'

alias vi=vim

alias cb='cd -'
alias ..=' ..'
alias ...=' ../..'
alias ....=' ../../..'

alias tree1='tree -L 1'
alias tree2='tree -L 2'
alias tree3='tree -L 3'

alias rm='rm -Iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias mkdir='mkdir -pv'

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias la='ls -A'
alias ll='ls -lh'
alias lla='ls -lhA'

alias py="python"
alias ipy="ipython"
alias pudb="pudb3"
alias pypath='python -c "import sys; [print(p) for p in filter(None, sys.path)]"'

alias open='xdg-open'
alias rg="rg --color=never -S"
alias http="http --style=algol"

# BINDINGS
# ----------------------------------------------------------------------------

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

bindkey '^e' end-of-line
bindkey '^a' beginning-of-line

bindkey -M vicmd '^k' edit-command-line
bindkey -M vicmd 'H' vi-beginning-of-line
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'Y' vi-yank-eol

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

# PLUGINS
# ----------------------------------------------------------------------------

if [[ -e "$ZDATADIR/ext/rofi.zsh" ]]; then
	source "$ZDATADIR/ext/rofi.zsh"
	bindkey '^[e' rofi-find
	bindkey '^[d' rofi-cd
	bindkey '^[r' rofi-history
fi

if [[ -e "$ZDATADIR/ext/zsh-autosuggestions/zsh-autosuggestions.zsh" && "$TERM" != "linux" ]]; then

	source "$ZDATADIR/ext/zsh-autosuggestions/zsh-autosuggestions.zsh"

	bindkey '^y' autosuggest-accept
	bindkey '^d' autosuggest-execute

fi

# LOCAL RC
# ----------------------------------------------------------------------------

if [ -f ~/.zshrc.local ]; then
	source ~/.zshrc.local
fi
