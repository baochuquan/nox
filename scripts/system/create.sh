#!/bin/sh

##############################################################################
##
##  Filename: create.sh
##  Author: baocq
##  E-mail: baochuquan@163.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_ROOT/common/utils.sh
source $NOX_ROOT/common/config.sh

# Usage of script-template.sh
function _usage_of_create() {
    cat << EOF
Usage:
    create --dir <dirname>
    create --script <scriptname>

Description:
    用于 nox 脚本开发，创建一个子目录或脚本

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --dir|-d:                                           -- 创建目录
    --script|-s:                                        -- 创建脚本

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

function create() {
    local debug=0
    local scriptName
    local dirName

    local ARGS=`ggetopt --options h,x,d:,s: --longoptions help,debug,dir:,script: -n 'Error' -- "$@"`
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
                _usage_of_create
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -d|--dir)
                dirName=$2
                shift 2
                ;;
            -s|--script)
                scriptName=$2
                scriptName=${scriptName%.*}
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

    local currentPath=`pwd`
    if [[ ! $currentPath =~ $NOX_SCRIPTS ]]; then
        error "Current path is not under $NOX_SCRIPTS"
        exit 1
    fi

    local ldap=`ldap`
    if [[ -z $ldap ]]; then
        exit 1
    fi

    # 创建目录
    if [[ ! -z $dirName ]]; then
        if [[ -x ${dirName}.sh ]]; then
            error "There is a shell script named \`${dirName}\` in current directory. Please use another directory name."
            exit 1
        fi

        if [[ -d ${dirname} ]]; then
            error "There is a sub directory named \`${dirName}\` in current directory. Please use another directory name."
            exit 1
        fi

        mkdir $dirName
        pushd "`pwd`/$dirName"
        cp $NOX_ROOT/templates/description-template .description
        echo "$dirName 相关功能" >> .description
        popd
    fi

    # 创建脚本
    if [[ ! -z $scriptName ]]; then
        if [[ -x ${scriptName}.sh ]]; then
            error "There is a shell script named \`${scriptName}\`. Please use another script name."
            exit 1  
        fi

        if [[ -d $scriptName ]]; then
            error "There is a sub directory named \`${scriptName}\`. Please use another script name."
            exit 1
        fi

        local underline=`echo $scriptName | sed "s/-/_/g"`
        cp $NOX_ROOT/templates/script-template.sh ${scriptName}.sh
        gsed -i "s/script-template/${scriptName}/g" ${scriptName}.sh
        gsed -i "s/script_template/${underline}/g" ${scriptName}.sh
        gsed -i "s/<ldap>/${ldap}/g" ${scriptName}.sh
        gsed -i "s/<date>/`date`/g" ${scriptName}.sh
    fi

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
create $*