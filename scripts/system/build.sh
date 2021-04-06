#!/bin/sh

##############################################################################
##
##  Filename: build.sh
##  Author: baocq
##  E-mail: baocq@fenbi.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_ROOT/common/utils.sh
source $NOX_ROOT/common/logo.sh

# Usage of script-template.sh
function _usage_of_build() {
    cat << EOF
Usage:
    build

Description:
    用于生成自动补全脚本

Option:
    --help|-h:                                          -- 使用帮助
    --debug|-x:                                         -- 调试模式
    --slient|-s:                                        -- 编译后不打印 Logo

EOF
}

autocompleteFile="$NOX_ROOT/fpath/_nox"

# 子目录
function subdirs() {
    echo `ls -l | awk '/^d/ {print $NF}'`
}

# 子文件
function subscripts() {
    echo `ls -l | awk '/.sh$/ {print $NF}'`
}

function _raw_name() {
    local origin=$1
    echo $origin | sed "s/^_//"
}

function _subcmds_from_description() {
    local spaceBase=$1
    local index

    declare subdirs=(`subdirs`)
    local dirCount=${#subdirs[*]}
    index=1
    while [[ $index -le $dirCount ]]; do
        local dirName=${subdirs[$index]}
        local descFile="${dirName}/.description"
        if [[ ! -f $descFile ]]; then
            warning "[nox] the \`.description\` file in ${dirName} is nox exist."
            warning "[nox] creating \`.description\` for ${dirName}..."
            echo "$dirName 相关功能" >> $descFile
        fi
        local descOfCmd=`cat $descFile | head -n 1`
        if [[ -z $descOfCmd ]]; then
            warning "[nox] the first line of \`$descFile\` is empty."
            warning "[nox] use default description for \`$descFile\`"
            descOfCmd="$dirName 相关功能"
        fi
        echo "`space $spaceCount`\"${subdirs[$index]}:$descOfCmd\"" >> $autocompleteFile
        index=$[ $index + 1 ]
    done

    declare subscripts=(`subscripts`)
    local scriptCount=${#subscripts[*]}
    index=1
    while [[ $index -le $scriptCount ]]; do
        local scriptName=${subscripts[$index]}
        local prefixName=${scriptName%.*}
        local start=`ggrep "Description" -n $scriptName | head -n 1 | cut -d ":" -f1`
        start=$[ $start + 1 ]
        local descOfScript=`cat $scriptName | tail -n +$start | head -n 1 | sed "s/^--//"`
        echo "`space $spaceCount`\"$prefixName:$descOfScript\"" >> $autocompleteFile
        index=$[ $index + 1 ]
    done
}

function _options_from_usage_of() {
    local spaceBase=$1
    local scriptName=$2
    local prefixName=${scriptName%.*}

    local start=`ggrep "^Option" -n $scriptName | head -n 1 | cut -d ":" -f1`
    local end=`ggrep "^EOF" -n $scriptName | head -n 1 | cut -d ":" -f1`
    local length=$[ $end - $start ]
    if [[ $length == 0 ]]; then
        warning "[nox] `_usage_of_${prefixName}` in `${scriptName}` did not define any options."
    fi
    local options=(`cat $scriptName | tail -n +$start | head -n $length | tr -d " " | tr -d '"' | tr "\n" " "`)
    local size=${#options[*]}
    local index=1
    while [[ $index -le $size ]]; do
        local content=${options[$index]}
        if [[ "$content" =~ ^--.+:.+ ]]; then
            local desc=`echo $content | cut -d ":" -f2 | sed "s/^--//"`
            local opts=`echo $content | cut -d ":" -f1`
            local opt1=`echo $opts | cut -d "|" -f1`
            local opt2=`echo $opts | cut -d "|" -f2`

            if [[ ! -z $opt1 && ! -z $desc ]]; then
                echo "[nox] building option \`${opt1}\` for subcommand \`${prefixName}\`; description: ${desc}"
                echo "`space $spaceBase`\"${opt1}:${desc}\"" >> $autocompleteFile
            fi

            if [[ ! -z $opt2 && ! -z $desc && $opt2 != $opt1 ]]; then
                echo "[nox] building option \`${opt2}\` for subcommand \`${prefixName}\`; description: ${desc}"
                echo "`space $spaceBase`\"${opt2}:${desc}\"" >> $autocompleteFile
            fi
        fi
        index=$[ $index + 1 ]
    done
}

function _options_from_script() {
    local spaceBase=$1
    local scriptName=$2
    local spaceCount=$spaceBase
    echo "`space $spaceCount`*)" >> $autocompleteFile

    spaceCount=$[ $spaceBase + 4 ]
    echo "`space $spaceCount`_options=(" >> $autocompleteFile

    spaceCount=$[ $spaceBase + 8 ]
    _options_from_usage_of $spaceCount $scriptName

    spaceCount=$[ $spaceBase + 4 ]
    echo "`space $spaceCount`)" >> $autocompleteFile

    echo "`space $spaceCount`_describe -t options \"nox `_cmds_from_path` $scriptName\" _options" >> $autocompleteFile

    spaceCount=$spaceBase
    echo "`space $spaceCount`;;" >> $autocompleteFile
}

function _cmds_from_path() {
    local cmds=`pwd | sed "s|^$NOX_SCRIPTS/||g" | sed "s|/| |g"`
    echo "$cmds"
}

function _dfs() {
    local cmdLevel=$1
    local prevCmd=$2

    local index
    local spaceCount
    local tmp

    # 子目录
    declare subdirs=(`subdirs`)
    local dirCount=${#subdirs[*]}

    tmp=$[ $cmdLevel + 1 ]
    spaceCount=$[ ($cmdLevel - 1) * 8 ]
    echo "`space $spaceCount`case \"\$words[${tmp}]\" in" >> $autocompleteFile
    index=1
    while [[ $index -le $dirCount ]]; do
        local dirName=${subdirs[$index]}
        echo "[nox] start building directory for subcommand \`$dirName\`..."
        pushd `pwd`"/${dirName}" >& /dev/null
        spaceCount=$[ ($cmdLevel - 1) * 8 + 4 ]

        echo "`space $spaceCount`${dirName})" >> $autocompleteFile
        _dfs $[ cmdLevel + 1 ] ${dirName}
        echo "`space $spaceCount`;;" >> $autocompleteFile

        popd >& /dev/null
        success "[nox] subcommand \`${dirName}\` build success."
        index=$[ index + 1 ]
    done

    # 子文件
    tmp=$[ $tmp + 1 ]
    declare subscripts=(`subscripts`)
    local scriptCount=${#subscripts[*]}
    index=1
    while [[ $index -le $scriptCount ]]; do
        spaceCount=$[ ($cmdLevel - 1) * 8 + 4 ]
        local scriptName=${subscripts[$index]}
        local prefixName=${scriptName%.*}
        echo "[nox] start building script for subcommand \`${prefixName}\`..."
        echo "`space $spaceCount`${prefixName})" >> $autocompleteFile

        spaceCount=$[ $spaceCount + 4 ]
        echo "`space $spaceCount`case \"\$words[${tmp}]\" in" >> $autocompleteFile
        spaceCount=$[ $spaceCount + 4 ]
        # 解析脚本 _usage_of_xxx
        _options_from_script $spaceCount $scriptName
        spaceCount=$[ $spaceCount - 4 ]
        echo "`space $spaceCount`esac" >> $autocompleteFile
        spaceCount=$[ $spaceCount - 4 ]
        echo "`space $spaceCount`;;" >> $autocompleteFile

        success "[nox] subcommand \`${prefixName}\` build success."
        index=$[ index + 1 ]
    done

    # subdirs 对应的子命令通配符处理
    echo "[nox] start analyzing .description ..."
    spaceCount=$[ ($cmdLevel - 1) * 8 + 4 ]
    echo "`space $spaceCount`*)" >> $autocompleteFile

    spaceCount=$[ $spaceCount + 4 ]
    if [[ $dirCount > 0 || $scriptCount > 0 ]]; then
        echo "`space $spaceCount`_subcommands=(" >> $autocompleteFile
        spaceCount=$[ $spaceCount + 4 ]
        _subcmds_from_description $spaceCount
        spaceCount=$[ $spaceCount - 4 ]
        echo "`space $spaceCount`)" >> $autocompleteFile
        echo "`space $spaceCount`_describe -t commands \"nox $prevCmd subcommands\" _subcommands" >> $autocompleteFile
    fi

    echo "`space $spaceCount`_options=(" >> $autocompleteFile
    spaceCount=$[ $spaceCount + 4 ]
    echo "`space $spaceCount`\"--help:使用帮助\"" >> $autocompleteFile
    echo "`space $spaceCount`\"-h:使用帮助\"" >> $autocompleteFile
    echo "`space $spaceCount`\"--debug:调试模式\"" >> $autocompleteFile
    echo "`space $spaceCount`\"-x:调试模式\"" >> $autocompleteFile
    spaceCount=$[ $spaceCount - 4 ]
    echo "`space $spaceCount`)" >> $autocompleteFile
    echo "`space $spaceCount`_describe -t options \"nox `_cmds_from_path` options\" _options" >> $autocompleteFile

    spaceCount=$[ $spaceCount - 4 ]
    echo "`space $spaceCount`;;" >> $autocompleteFile
    spaceCount=$[ $spaceCount - 4 ]
    echo "`space $spaceCount`esac" >> $autocompleteFile
    echo "[nox] analyzing .description finished!"
}

function build() {
    local debug=0
    local slient=0

    local ARGS=`ggetopt -o h,x,s --long help,debug,slient -n 'Error' -- "$@"`
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
                _usage_of_build
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -s|--slient)
                slient=1
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

    # 入口
    if [[ ! -d $NOX_ROOT/fpath ]]; then
        echo "[nox] Creating directory: ${NOX_ROOT}/fpath"
        mkdir $NOX_ROOT/fpath
    fi

    echo "#compdef nox" > $autocompleteFile
    echo "" >> $autocompleteFile
    echo "# ------------------------------------------------------------------------" >> $autocompleteFile
    echo "# " >> $autocompleteFile
    echo "# FILE: _nox" >> $autocompleteFile
    echo "# DESCRIPTION: Generated by \`nox system build\`. Do not modify this file !" >> $autocompleteFile
    echo "# " >> $autocompleteFile
    echo "# ------------------------------------------------------------------------" >> $autocompleteFile
    echo "" >> $autocompleteFile
    echo "local -a _subcommands" >> $autocompleteFile
    echo "local -a _options" >> $autocompleteFile
    echo "" >> $autocompleteFile

    pushd $NOX_SCRIPTS >& /dev/null
    local cmdLevel=1
    _dfs $cmdLevel
    popd >& /dev/null

    if [[ $slient == 0 ]]; then
        success ""
        print_logo
        success "                                                                   ... build success !"
        success ""
        success "        Before you use nox! Please execute \"source ~/.zshrc\" to make sure that the nox configurations are ready!"
        success ""
    fi

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
build $*