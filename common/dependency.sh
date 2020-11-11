#!/bin/sh

source $NOX_ROOT/common/utils.sh

function check_dependency() {
    local target=$1
    echo "[nox] checking $target..."
    brew list $target >& /dev/null
}

function install_dependency() {
    local target=$1
    echo "[nox] installing $target..."
    brew install $target > /dev/null
}

# 安装 NOX 所需的依赖
function register_nox_dependency() {
    export HOMEBREW_NO_AUTO_UPDATE=1

    echo "[nox] start installing system dependencies..."
    # Installing gnu-getopt
    local GGETOPT="/usr/local/bin/ggetopt"
    if [[ ! -x $GGETOPT ]]; then
        (check_dependency gnu-getopt) || (install_dependency gnu-getopt)
        local GNU_GETOPT=`brew list gnu-getopt | grep "bin"`
        ln -s $GNU_GETOPT $GGETOPT
    fi

    # Installing yq
    (check_dependency yq) || (install_dependency yq)

    # Read brewspec.yaml to install custom dependencies
    local brewspecFile="$NOX_CONFIG/brewspec.yaml"
    local count=`yq r $brewspecFile --length dependencies`
    if [[ -z $count || $count -lt 1 ]]; then
        echo "[nox] \`$NOX_CONFIG/brewspec.yaml\` did not define any brew dependency."
    else
        echo "[nox] start installing brew dependencies..."
        local items=(`yq r $brewspecFile dependencies | sed "s/^- //" | tr "\n" " "`)
        for item in $items; do
            (check_dependency $item) || (install_dependency $item)
        done
    fi 
}

function unregister_nox_dependency() {
    local GGETOPT="/usr/local/bin/ggetopt"
    if [[ -x $GGETOPT ]]; then
        rm $GGETOPT
    fi
}