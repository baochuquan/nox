#!/bin/sh

##############################################################################
##
##  Filename: lunch.sh
##  Author: baocq
##  E-mail: baocq@fenbi.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_COMMON/utils.sh

# Usage of launch.sh
function _usage_of_lunch() {
    cat << EOF
Usage:
    lunch

Description:
    午饭吃什么？在 config.yaml 中的 restaurants 餐厅列表中随机选择一个餐厅

Option:
    --help|-h:                                          -- 使用帮助
    --debug|-x:                                         -- 调试模式
EOF
}

# getopt 命令格式说明:
#   -o: 表示定义短选项
#       示例解释: ab:c:: 定义了三个选项类型。
#           a 后面未带冒号，表示定义的 a 选项是开关类型(true/false)，不需要额外参数，使用 -a 选项即表示true。
#           b 后面带冒号，表示定义的 b 选项需要额外参数，如: -b 30
#           c 后面带双冒号，表示定义的 c 选项有一个可选参数，可选参数必须紧贴选项，如: -carg 而不能是 -c arg
#   -long: 表示定义长选项
#       示例解释: a-long,b-long:,c-long::。含义与上述基本一致。
#   "$@": 表示参数本身的列表，也不包括命令本身
#   -n: 表示出错时的信息
#   --:
#       如何创建一个 -f 的目录
#       mkdir -f 会执行失败，因为 -f 会被 mkdir 当做选项来解析
#       mkdir -- -f 会执行成功，-f 不会被当做选项

function lunch() {
    local debug=0

    local ARGS=`ggetopt -o h,x --long help,debug -n 'Error' -- "$@"`
    if [ $? != 0 ]; then
        error "Invalid option..." >&2;
        exit 1;
    fi
    # 重新排列参数的顺序
    eval set -- "$ARGS"
    # 经过 getopt 的处理，下面处理具体选项。
    while true ; do
        case "$1" in
            -h|--help)
                _usage_of_lunch
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

    local configFile="$NOX_CONFIG/config.yaml"
    local count=`yq r $configFile --length restaurants`
    if [[ -z $count || $count -lt 1 ]]; then
        error "The value of key \`restaurants\` $NOX_CONFIG/config.yaml is not defined. Please initialize it as a array. See example in \`$NOX_TEMPLATES/config-template.yaml.\`"
        exit 1
    fi

    local options=(`yq r $configFile restaurants | sed "s/^- //" | tr "\n" " "`)
    printf "今天中午去哪儿吃？"
    tput sc
    seq 1 1000 | while read i; do
        local index=$[ $RANDOM % $count + 1 ]
        tput rc
        tput el
        printf "${options[$index]}"
    done
    printf "\n"

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
lunch $*