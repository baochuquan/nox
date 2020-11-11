#!/bin/sh

source $NOX_COMMON/variables.sh

# Judge whether a command exists or not
function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

# Print error into stdout
function error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

# Print success into stdout
function success() {
	echo ${GREEN}"$@"${RESET} >&2
}

# Print warning
function warning() {
    echo ${YELLOW}"$@"${RESET} >&2
}

# Print underline content
function underline() {
    echo "$(printf '\033[4m')$@$(printf '\033[24m')"
}

# Print spaces witch specific count
function space() {
    if [[ $1 -le 0 ]]; then
        echo ""
    else
        seq -s " " $1 | tr -d "[:digit:]"
    fi
}