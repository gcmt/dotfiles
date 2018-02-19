
export PATH="$HOME/.local/bin:$PATH"

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]
then
	exec startx
	exit 0
fi
