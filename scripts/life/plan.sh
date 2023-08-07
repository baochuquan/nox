#!/bin/sh

##############################################################################
##
##  Filename: plan.sh
##  Author: lizhe
##  E-mail: 
##  Date: 2022年 3月15日 星期二 17时56分37秒 CST
##
##############################################################################

source $NOX_COMMON/utils.sh
source $NOX_COMMON/config.sh


# Usage of plan.sh
function _usage_of_plan() {
    cat << EOF
Usage:
    plan -a <计划内容>
    plan -t
    plan -f <计划序号>
    plan -r <计划序号>

Description:
    plan 相关功能

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --add|-a:                                           -- 添加计划, 参数为今天计划内容
    --today|-t:                                         -- 查看今日计划
    --finish|-f:                                        -- 完成计划, 参数为今天计划序号
    --remove|-r:                                        -- 移除计划, 参数为今天计划序号

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

function plan() {
    local debug=0
    local show_plan=0
    local today=$(date -v-0d +"%y-%m-%d")
    local file=$NOX_CACHE/$today.csv
    [ ! -f "$file" ] && touch $file

    local ARGS=`ggetopt -o h,x,a:tf:r: --long help,debug,add:,today:,finish:,remove: -n 'Error' -- "$@"`
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
                _usage_of_plan
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -a|--add)
                echo "add plan $2"
                (cat $file ; echo $2) > $file.bak
                cat $file.bak > $file
                shift 2
                ;;
            -t|--today)
                show_plan=1
                shift
                ;;
            -f|--finish)
                echo "finish plan index: $2"
                local get_order=NR==$2
                local data=$(awk $get_order $file)
                if [[ $data =~ "(DONE)" ]]
                then
                    echo "plan has finish!"
                else
                    local data_done="$data(DONE)"
                    local order=NR!=$2
                    (awk $order $file) > $file.bak
                    cat $file.bak > $file
                    # append finish plan
                    (cat $file ; echo $data_done) > $file.bak
                    cat $file.bak > $file
                fi
                shift 2
                ;;
            -r|--remove)
                echo "remove plan $2"
                local order=NR!=$2
                (awk $order $file) > $file.bak
                cat $file.bak > $file
                shift 2
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

    if [[ $debug == 1 ]]; then
        set +x
    fi


    if [[ $show_plan == 1 ]]; then
        echo "today plan:"
        awk '{str=NR" "$1;if(match($1, "(DONE)")==0)print "\033[1;31m"str" \033[0m"; else print "\033[1;32m"str" \033[0m" }' $file
    fi
}

# Execute current script
plan $*