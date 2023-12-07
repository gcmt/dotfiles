
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/lib/node_modules/bin:$PATH"
export PATH="$HOME/.local/go/bin:$PATH"
export npm_config_prefix=~/.local/lib/node_modules

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]
then
	exec startx
	exit 0
fi
