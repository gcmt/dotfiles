
tmux() {
	command tmux -f $XDG_CONFIG_HOME/tmux.conf "$@"
}

t() {
	local name=${1:-default}
	local bootstrap="$XDG_DATA_HOME/tmux/templates/$name"
	tmux has-session -t "$name" 2>/dev/null
	if [ $? != 0 ]; then
		if [ -x "$bootstrap" ]; then
			source "$bootstrap"
		else
			tmux new-session -s "$name" -d
		fi
	fi
	if [ -z "$TMUX" ]; then
		tmux attach-session -t "$name"
	else
		tmux switch-client -t "$name"
	fi
}
