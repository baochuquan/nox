#!/bin/sh

##############################################################################
##
##  Filename: o2s-mtl.sh
##  Author: baocq
##  E-mail: baocq@fenbi.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_ROOT/common/utils.sh

# Usage of script-template.sh
function _usage_of_o2s_mtl() {
    cat << EOF
Usage:
    o2s-mtl --file <filename-with-out-suffix>

Description:
    将继承自 MTLModel 的 OC 类转换成 Swift 类

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --file|-f:                                          -- 待转换的文件名，不带文件格式后缀
EOF
}

function _property_name() {
    local name=`echo $@ | cut -d ")" -f2 | cut -d "/" -f1 | awk '{print $NF}' | sed "s/\*//" | sed "s/;//"`
    echo $name
}

function _property_type() {
    local line=$@
    local type_name=`echo $line | cut -d ")" -f2 | cut -d "/" -f1`
    local name=`_property_name $line`
    local type=`echo $type_name | sed "s/$type_name;//"`
    local result
    local count=0

    while echo $type | grep "NSArray<" > /dev/null; do
        count=$[ $count + 1 ]
        result=$result"["
        type=`echo $type | sed "s/NSArray<//"`
    done

    if echo $type | grep "NSString" > /dev/null; then
        result=$result"String"
    elif echo $type | grep "NSNumber" > /dev/null; then
        result=$result"Int"
    elif echo $type | grep "NSInteger" > /dev/null; then
        result=$result"Int"
    elif echo $type | grep "NSUInteger" > /dev/null; then
        result=$result"UInt"
    elif echo $type | grep "BOOL" > /dev/null; then
        result=$result"Bool"
    elif echo $type | grep "CGFloat" > /dev/null; then
        result=$result"CGFloat"
    elif echo $type | grep "int64_t" > /dev/null; then
        result=$result"Int64"
    elif echo $type | grep "NSTimeInterval" > /dev/null; then
        result=$result"TimeInterval"
    else
        local result=$result`echo $type | cut -d " " -f1`
    fi

    local tmp=$count
    while [ $tmp -gt 0 ]; do
        tmp=$[ $tmp - 1 ]
        result=$result"]"
    done

    local isOptional=0
    if echo $line | grep "nullable" > /dev/null; then
        isOptional=1
    fi
    if [[ $isOptional == 1 ]]; then
        result=$result"?"
    fi
    echo $result
}

function _comment() {
    local line=$@
    local comment

    if echo $line | grep "//" > /dev/null; then
        comment="// "`echo $line | awk -F "/" '{print $NF}'`
    fi
    echo $comment
}

function _property_value() {
    local line=$@
    local type=`_property_type "$line"`
    if echo $type | grep "?" > /dev/null; then
        echo ""
        return
    fi

    local count=`echo $type | grep -o "\[" | wc -l`
    local result
    if [[ $count -gt 0 ]]; then
        while [[ $count -gt 0 ]]; do
            result="["$result"]"
            count=$[ $count - 1 ]
        done
    else
        if echo $type | grep "String" > /dev/null; then
            result='""'
        elif echo $type | grep "Int" > /dev/null; then
            result="0"
        elif echo $type | grep "UInt" > /dev/null; then
            result="0"
        elif echo $type | grep "Bool" > /dev/null; then
            result="false"
        elif echo $type | grep "CGFloat" > /dev/null; then
            result="0.0"
        elif echo $type | grep "int64" > /dev/null; then
            result="0"
        elif echo $type | grep "TimeInterval" > /dev/null; then
            result="0"
        else
            result="UNKNOWN"
        fi
            #statements
    fi
    echo "= $result"
}

function _method_type() {
    local line=$@
    if echo $line | grep "\+ (" > /dev/null; then
        echo "class"
    else
        echo ""
    fi
}

function _method_return_type() {
    local line=$@
    local type=`echo $line | cut -d ")" -f1 | cut -d "(" -f2`
    type=`_property_type "$type"`
    echo "$type"
}

function _method_name() {
    local line=$@
    local returnType=`echo $line | cut -d ")" -f1`
    local method=`echo $line | sed "s/$returnType//"`
    if [[ ${method:0:1} == "*" ]]; then
        method=${method:2}
    elif [[ ${method:0:1} == ")" ]]; then
        method=${method:1}
    fi
    method=`echo $method | cut -d ";" -f1`

    local name=`echo $method | cut -d ":" -f1`
    local params=`echo $method | sed "s/$name//"`
    if [[ ! -z $params ]]; then
        params="_"$params
    fi

    method=$name"("

    local count=0
    local length=${#params}
    local oParam
    local iParam
    local pType
    local offset
    while [[ ! -z "$params" ]]; do
        local order=$(( $count % 3 ))
        if [[ $order == 0 ]]; then
            local pre=`echo $method | rev`
            pre=${pre:0:1}
            if [[ $pre != "(" ]]; then
                method=$method", "
            fi
            oParam=`echo $params | cut -d ":" -f1`
            offset=`echo $params | ggrep -b -o ":" | cut -d ":" -f1 | head -n1`
            offset=$[ $offset + 1 ]
            params=${params:$offset}
            method=$method$oParam" "
            count=$[ $count + 1 ]
        elif [[ $order == 1 ]]; then
            local tmp=`echo $params | cut -d ")" -f1 | tr -d "("`
            pType=`_property_type "$tmp"`
            offset=`echo $params | ggrep -b -o ")" | cut -d ":" -f1 | head -n1`
            offset=$[ $offset + 1 ]
            params=${params:$offset}

            iParam=`echo $params | cut -d " " -f1`
            offset=`echo $params | cut -d " " -f1 | head -n1`
            if [[ $offset == $iParam ]]; then
                offset=${#offset}
            fi
            offset=$[ $offset + 1 ]
            params=${params:$offset}

            method=$method$iParam": "$pType
            count=$[ $count + 2 ]

        fi
    done
    method=$method")"

    echo $method
}

function o2s_mtl() {
    local debug=0
    local prefix;
    local hFile;
    local mFile;

    local ARGS=`ggetopt -o h,x,f: --long help,debug,file:, -n 'Error' -- "$@"`
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
                _usage_of_o2s_mtl
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -f|--file)
                prefix=$2
                hFile="$2.h"
                mFile="$2.m"
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

    if [[ -z $hFile ]]; then
        _usage_of_o2s_mtl
        exit 1
    fi

    # 检查文件内容是否符合
    if ! grep "@interface .* MTLModel<MTLJSONSerializing>" > /dev/null $hFile; then
        error "the class declared in $hFile is not inherited from MTLModel<MTLJSONSerializing>"
        exit 1
    fi

    # 处理头文件
    local typeStart=0
    local typeEnum
    local typeCase
    local typeValue
    local typeComment
    local propertyType
    local propertyName
    local propertyValue
    local propertyComment
    local methodType
    local methodReturnType
    local methodName
    local commentAllow=0
    local methodStart=0
    while read line; do
        if echo $line | grep "#import <Mantle\/Mantle.h>" > /dev/null; then
            commentAllow=1
            success ""
            success "import Foundation"
            success "import Mantle"
            success ""
        fi

        if [[ ${line:0:2} == "//" && $commentAllow == 1 ]]; then
            success "    "$line
        fi

        if echo $line | grep "typedef NS_ENUM(NSInteger," > /dev/null; then
            typeEnum=`echo $line | sed 's/typedef NS_ENUM(NSInteger, \(.*\)).*/\1/'`
            success "@objc"
            success "enum $typeEnum: Int {"
            typeStart=1
        elif [[ $typeStart == 1 ]]; then
            if echo $line | grep "$typeEnum" > /dev/null; then
                typeCase=`echo $line | cut -d "/" -f1 | tr -d ' ' | tr -d ',' | tr -d '=' | tr -d '0-9' | sed "s/$typeEnum//" | awk '{print tolower(substr($0,0,1))substr($0,2)}'`
                typeValue=`echo $line | cut -d "/" -f1 | cut -d '=' -f2 | tr -d ' ' | tr -d ','`
                if [ ! -z $typeValue ]; then
                    typeValue="= "$typeValue
                fi
                typeComment=`_comment $line`
                success "    case $typeCase $typeValue    $typeComment"
                typeValue=""
            elif echo $line | grep "^\};" > /dev/null; then
                success "}"
                success ""
                typeStart=0
            fi
        fi

        if echo $line | grep "@interface .* MTLModel<MTLJSONSerializing>" > /dev/null; then
            local class=`echo $line | gsed 's/@interface \(.*\) : MTLModel<MTLJSONSerializing>/\1/'`
            success "@objcMembers"
            success "class $class: MTLModel, MTLJSONSerializing {"
        fi

        if echo $line | grep "@property" > /dev/null; then
            propertyType=`_property_type "$line"`
            propertyName=`_property_name $line`
            propertyValue=`_property_value $line`
            propertyComment=`_comment $line`
            success "    var $propertyName: $propertyType $propertyValue       $propertyComment"
        fi

        if echo $line | grep "[+|-]" > /dev/null; then
            if [[ $methodStart == 0 ]]; then
                methodStart=1
                success ""
            fi
            methodType=`_method_type $line`
            if [[ ! -z $methodType ]]; then
                methodType=$methodType" "
            fi
            methodReturnType=`_method_return_type $line`
            methodName=`_method_name $line`
            success "    ${methodType}func $methodName -> $methodReturnType {}"
            success ""
        fi

    done < $hFile

    # 处理实现文件
    success ""
    success "    class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any]! {"
    success "        return [:]"
    success "    }"
    success ""

    # 结束
    success "}"
    success ""

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
o2s_mtl $*