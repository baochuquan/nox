#!/bin/sh

##############################################################################
##
##  Filename: script-template.sh
##  Author: <ldap>
##  E-mail: 
##  Date: <date>
##
##############################################################################

source $NOX_COMMON/utils.sh
source $NOX_COMMON/config.sh

# Usage of script-template.sh
function _usage_of_script_template() {
    cat << EOF
Usage:
    script-template --a-long --b-long argB --c-long argC

Description:
    script-template related usage.

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --a-long|-a:                                        -- boolean option
    --b-long|-b:                                        -- option with one parameter
    --c-long|-c:                                        -- option with an optional parameter

EOF
}

##########################################################################################################################
#
# English note
# getopt command format description:
#   -o: means define short option
#       Example explanation: `ab:c::` defines three option types.
#           a There is no colon after a, which means that the defined a option is a switch type (true/false), and no additional parameters are required. Using the -a option means true.
#           b Followed by a colon, it means that the defined b option requires additional parameters, such as: `-b 30`
#           c Followed by a double colon, it means that the defined c option has an optional parameter, and the optional parameter must be close to the option, such as: `-carg` instead of `-c arg`
#   -long: means define long options
#       Example explanation: `a-long,b-long:,c-long::`. The meaning is basically the same as above.
#   "$@": 表示参数本身的列表，也不包括命令本身
#   -n: 表示出错时的信息
#   --: A list representing the arguments themselves, not including the command itself
#       How to create a directory with -f
#       `mkdir -f` will fail because -f will be parsed as an option by mkdir
#       `mkdir -- -f` will execute successfully, -f will not be considered as an option
#
##########################################################################################################################
#
# 中文注释
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
#
##########################################################################################################################

function script_template() {
    local debug=0

    local ARGS=`ggetopt -o hxab:c:: --long help,debug,a-long,b-long:,c-long:: -n 'Error' -- "$@"`
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
                _usage_of_script_template
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -a|--a-long)
                echo "Option a"
                shift
                ;;
            -b|--b-long)
                echo "Option b, argument $2'"
                shift 2
                ;;
            -c|--c-long)
                # c has an optional argument. As we are in quoted mode, an empty parameter will be generated if its optional argument is not found.
                case "$2" in
                    "")
                        echo "Option c, no argument"
                        shift 2
                        ;;
                    *)
                        echo "Option c, argument $2'"
                        shift 2
                        ;;
                esac
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
    echo "script_template start ..."

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
script_template $*