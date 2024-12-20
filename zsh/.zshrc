
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

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _expand_alias _extensions _complete _match _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*:approximate:*' max-errors 3
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' format '%B-- %d%b'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} "ma=7;1"
zstyle ':completion:*:messages' format '%B-- %d%b'
zstyle ':completion:*:descriptions' format '%B-- %d%b'
zstyle ':completion:*:corrections' format '%B!! %d (errors %e)%b'
zstyle ':completion:*:warnings' format '%B-- no match for: %d%b'
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*' file-list all

# ignore EOF in tmux
[ -n "$TMUX" ] && setopt ignoreeof

# allow ctrl-s and ctrl-q bindings to be used
stty -ixon

# HOOKS
# ----------------------------------------------------------------------------

autoload -U add-zsh-hook

set-title() {
    if [[ -n "$TMUX" || -n "$RANGER_LEVEL" || -n "$VIFM_SERVER" ]]; then
        return
    fi
    print -n "\e]2;$PWD - Terminal\a"
}
add-zsh-hook precmd set-title

# VI MODE
# ----------------------------------------------------------------------------

bindkey -v

zle_highlight=(default:bold)

# use different colors for each mode
zle-keymap-select() {
    case $KEYMAP in
        viins|main) zle_highlight=(default:bold) ;;
        vicmd) zle_highlight=(default:bold,fg=22) ;;
    esac
}
zle -N zle-keymap-select

zle-line-init() {
  zle -K viins
}
zle -N zle-line-init

# PROMPT
# ----------------------------------------------------------------------------

autoload -Uz colors vcs_info
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats "%F{21}%f%b"

setopt prompt_subst

_prompt_info() {
    local info=
    if [[ -n "$VIFM_SERVER" ]]; then
        info+="  vifm  "
    fi
    if [[ -n "${VIRTUAL_ENV}" ]]; then
        info+="  $(basename "${VIRTUAL_ENV}")  "
    fi
    vcs_info
    local vcs="${vcs_info_msg_0_}"
    if [[ -n "${vcs}" ]]; then
        info+="  ${vcs}  "
    fi
    if [[ -n "${info}" ]]; then
        echo -n "${info}"
    fi
}

_prompt_cwd() {
    case $PROMPT_TRIMDIR in
        0) echo -n "%3~" ;;
        1) echo -n "%~" ;;
    esac
}

_prompt_divider() {
    if [[ -n $PROMPT_SEP ]]; then
        echo "%F{23}${(l:$COLUMNS::─:)}%f"
    fi
}

preexec() {
    PROMPT_SEP=1
}

PROMPT_TRIMDIR=0

PROMPT='$(_prompt_divider)'
PROMPT+='%F{23}─ %f%F{red}%(?.. %?  )%f%(1j. %j  .)'
PROMPT+='$(_prompt_info)  $(_prompt_cwd)    '

# FUNCTIONS
# ----------------------------------------------------------------------------

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

poet() {
    POET_MANUAL=1
    if [[ -v VIRTUAL_ENV ]]; then
        deactivate
    else
        source "$(poetry env info --path)/bin/activate"
    fi
}

vimx() {
    touch "$@" && chmod u+x "$@" && nvim "$@"
}

# open files that contain the given pattern
vimg() {
    nvim -q <(rg --vimgrep "$@") +copen
}

# search and open files with vim
vimf() {
    local flist=$(mktemp -d)/filelist
    rg --files \
        -g "!node_modules/*" -g "!venv/*" -g "!dist/*" -g "!build/*" \
        -g "!*.pyc" -g "!*.beam" -g "!*.pdf" -g "!*.jpg" -g "!*.png" -g "!*.gif" -g "!*.mp4" -g "!*.gpg" \
        | grep "$(echo "$@" | sed 's/\s\+/.*/')" > "$flist"
    if [[ -s "$flist" ]]; then
        nvim "$flist" \
            -c "argd %" \
            -c "setl nomodifiable" \
            -c "nn <silent> <buffer> gf :set bl<bar>norm! ^vg_gf<cr>" -c "nmap <buffer> l gf" \
            -c "nn <silent> <buffer> gF :set nobl<bar>norm! ^vg_gf<cr>" -c "nmap <buffer> L gF"
    else
        echo >&2 "$0: nothing found"
        return 1
    fi
}

# create directory and move into it
mcd() {
    mkdir -p "$@" && cd "$@"
}
compdef mcd=mkdir

g() {
    [ $# -eq 0 ] && git status || git "$@"
}
compdef g=git

d() {
    [ $# -eq 0 ] && docker info || docker "$@"
}
compdef d=docker

ledger() {
    if [[ -n "${LEDGER_FILE}" ]]; then
        echo "Using ${LEDGER_FILE}" >&2
        command ledger -f "${LEDGER_FILE}" "$@"
    else
        command ledger "$@"
    fi
}

ledit() {
    cd "${LEDGER_DIR}"
    nvim -c 'norm! G' "${LEDGER_DIR}/g.$(date +%Y).ledger"
}

# ALIASES
# ----------------------------------------------------------------------------

alias ze='nvim $ZDOTDIR/.zshrc'
alias zs='source $ZDOTDIR/.zshrc'
alias zh='vim -c "norm! G" ~/.local/share/zsh/history'

alias dark='colorscheme dark'
alias light='colorscheme light'

alias cb='cd -'
alias ..=' ..'
alias ...=' ../..'
alias ....=' ../../..'

alias tree="tree -I 'node_modules|cache|__pycache__|venv|*.egg-info'"
alias tree1='tree -L 1'
alias tree2='tree -L 2'
alias tree3='tree -L 3'

alias rm='rm -Iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias mkdir='mkdir -pv'

export LS_COLORS="di=34:ln=36:so=32:pi=35:ex=31"
alias ls='LC_COLLATE=C ls --time-style=long-iso --color=auto --group-directories-first --quoting-style=literal'
alias la='ls -A'
alias ll='ls -lh'
alias lla='ls -lhA'

alias py="python"
alias ipy="ipython"
alias pudb="pudb3"
alias pypath='python -c "import sys; [print(p) for p in filter(None, sys.path)]"'

alias vim='nvim'
alias whose='pacman -Qo'
alias open='xdg-open'
alias rg="rg --color=never -S"
alias http="http --style=algol"
alias update="systemd-inhibit sudo pacman -Syu"
alias mktree='mktree -v'
alias ncdu="ncdu --color off"

# WIDGETS
# ----------------------------------------------------------------------------

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

trim-prompt-cwd() {
    PROMPT_TRIMDIR=$((1 - PROMPT_TRIMDIR))
    zle reset-prompt
}
zle -N trim-prompt-cwd

# delete Nth command line argument
delete-argument() {
    local words=(${(z)BUFFER})
    [[ -z "$words" ]] && return 1
    local target="${NUMERIC:-1}"
    if [[ "${words[1]}" == "sudo" ]]; then
        (( target += 1 ))
    fi
    local pos=0 out=()
    for i in {1..${#words[@]}}; do
        (( i < target ))  && pos=$(( pos + ${#${words[i]}} + 1 ))
        (( i != target )) && out[$i]="${words[i]}"
    done
    BUFFER="$out[*]"
    CURSOR="$pos"
}
zle -N delete-argument

# add timestamp every time a command is executed
accept-line-timestamp() {
    if [[ -n $BUFFER ]]; then
        RPROMPT='%F{22}󰥔  %*%f'
    fi
    zle reset-prompt
    zle accept-line
    RPROMPT=
}
zle -N accept-line-timestamp


tmux-next-pane() {
    tmux select-pane -t +
}
zle -N tmux-next-pane

# FZF
# ----------------------------------------------------------------------------

if hash "fzf" 2>/dev/null; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh

    export FZF_DEFAULT_OPTS="-e --multi --tmux 90% --reverse --border sharp"
    FZF_DEFAULT_OPTS+=" --preview 'fzf-preview {}' --preview-window border-left"
    FZF_DEFAULT_OPTS+=" --bind TAB:down,SHIFT-TAB:up --bind CTRL-N:toggle+down,CTRL-L:toggle+down,CTRL-H:toggle+up,RIGHT:toggle+down,LEFT:toggle+up"
    FZF_DEFAULT_OPTS+=" --color fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23,gutter:-1,border:22"

    export FZF_DEFAULT_COMMAND="rg --files --hidden --no-require-git -g '!.git/'"
    export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND

    export FZF_ALT_C_OPTS="--preview 'tree -L1 -C {} | head -100'"
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden"

    bindkey -M vicmd '^F' fzf-file-widget
    bindkey -M viins '^F' fzf-file-widget
    bindkey -M vicmd '^E' fzf-cd-widget
    bindkey -M viins '^E' fzf-cd-widget
fi

# BINDINGS
# ----------------------------------------------------------------------------

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# pageup/pagedown
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey '^w' backward-delete-word
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

bindkey '^e' end-of-line
bindkey '^a' beginning-of-line

bindkey -M vicmd 'H' vi-beginning-of-line
bindkey -M vicmd 'L' vi-end-of-line
bindkey -M vicmd 'Y' vi-yank-eol

bindkey '^k' edit-command-line
bindkey -M vicmd '^k' edit-command-line
bindkey -M vicmd v edit-command-line

bindkey '^q' push-line-or-edit

bindkey '^s' toggle-sudo
bindkey -M vicmd '^s' toggle-sudo

bindkey '\et' trim-prompt-cwd
bindkey -M vicmd '\et' trim-prompt-cwd

bindkey "^M" accept-line-timestamp

for i in {1..4}; do
    eval "delete-argument-$i() { NUMERIC=$i zle delete-argument }"
    zle -N delete-argument-$i
    bindkey "\\e$i" delete-argument-$i
done

bindkey "^t" tmux-next-pane

# LOCAL RC
# ----------------------------------------------------------------------------

if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
