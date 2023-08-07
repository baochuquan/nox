#!/bin/sh

source $NOX_ROOT/common/utils.sh

function _usage_of_nox() {
    cat << EOF
Usage:
    nox subcmd1 [subcmd2] [-option] [value] ...

Description:
    使用 Tab 提示，选择对应的子命令，从而索引到指定的脚本。使用选项/参数为脚本提供运行参数。

Option:
    --help|-h:                                                  -- using help
    --debug|-x:                                                 -- debug mode

EOF
}

function _search_and_execut_script() {
    local path="$NOX_SCRIPTS"
    while [[ ! -z $1 && ! $1 =~ ^- ]]; do
        path="$path/$1"
        shift 1
    done
    local script="$path.sh"
    if [[ ! -x $script ]]; then
        error "$script not exist."
        exit 1
    fi
    zsh $script $*
}

function nox() {
    if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]]; then
        _usage_of_nox
        exit 1
    fi

    if [[ $1 == "-x" || $1 == "--debug" ]]; then
        set -x
    fi

    _search_and_execut_script $*

    if [[ $1 == "-x" || $1 == "--debug" ]]; then
        set +x
    fi
}

nox $*
