
alias py3="python3"
alias ipy3="ipython3"

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
}
