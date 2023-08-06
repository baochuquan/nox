#!/bin/sh

##############################################################################
##
##  Filename: update.sh
##  Author: baocq
##  E-mail: baochuquan@163.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_ROOT/common/utils.sh
source $NOX_ROOT/common/logo.sh

# Usage of update.sh
function _usage_of_update() {
    cat << EOF
Usage:
    update

Description:
    update nox 

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode

EOF
}

# getopt 命令格式说明:
#   --options: 表示定义短选项
#       示例解释: ab:c:: 定义了三个选项类型。
#           a 后面未带冒号，表示定义的 a 选项是开关类型(true/false)，不需要额外参数，使用 -a 选项即表示true。
#           b 后面带冒号，表示定义的 b 选项需要额外参数，如: -b 30
#           c 后面带双冒号，表示定义的 c 选项有一个可选参数，可选参数必须紧贴选项，如: -carg 而不能是 -c arg
#   --longoptions: 表示定义长选项
#       示例解释: a-long,b-long:,c-long::。含义与上述基本一致。
#   "$@": 表示参数本身的列表，也不包括命令本身
#   -n: 表示出错时的信息
#   --:
#       如何创建一个 -f 的目录
#       mkdir -f 会执行失败，因为 -f 会被 mkdir 当做选项来解析
#       mkdir -- -f 会执行成功，-f 不会被当做选项

function update() {
    local debug=0

    local ARGS=`ggetopt --options h,x --longoptions help,debug -n 'Error' -- "$@"`
    if [ $? != 0 ]; then
        error "Invalid option..." >&2;
        exit 1;
    fi
    # rearrange the order of parameters
    eval set -- "$ARGS"
    # after being processed by getopt, the specific options are dealt with below.
    while true ; do
        case "$1" in
            -h|--help)
                _usage_of_update
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                error "Internal Error!"
                exit 1
                ;;
        esac
    done

    if [[ $debug == 1 ]]; then
        set -x
    fi

    # start
    pushd $NOX_ROOT >& /dev/null
    echo "[nox] ========================================"
    echo "[nox] start updating features..."
    git pull --rebase >& /dev/null
    if [[ $? != 0 ]]; then
        warning "[nox] cannot pull with rebase: You have unstaged changes."
        warning "[nox] please commit or stash them."
        echo "[nox] skip updating features..."
    fi
    source $NOX_COMMON/dependency.sh
    echo "[nox] ========================================"
    echo "[nox] start updating dependencies..."
    export HOMEBREW_NO_AUTO_UPDATE=1
    register_nox_dependency

    echo "[nox] ========================================"
    echo "[nox] start building completions..."
    nox system build -s

    success ""
    print_colorful_logo
    success "                                                                   ... update finished !"
    success ""
    success "        Before you use nox! Please execute \"source ~/.zshrc\" to make sure that the nox configurations are ready!"
    success ""
    popd >& /dev/null

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
update $*