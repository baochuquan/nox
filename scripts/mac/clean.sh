#!/bin/sh -x

##############################################################################
##
##  Filename: baocq.sh
##  Author: baocq
##  E-mail: baocq@fenbi.com
##  Date: Sun Oct 25 22:09:03 CST 2020
##
##############################################################################

source $NOX_ROOT/common/utils.sh

# Usage of script-template.sh
function _usage_of_mac_clean() {
    cat << EOF
Usage:
    clean

Description:
    清理 Mac 存储空间

Option:
    --help|-h:                                          -- 使用帮助
    --debug|-x:                                         -- 调试模式
    --without-derived-data|-d:                          -- 不清空 DerivedData 目录
EOF
}

function _bytes_to_human() {
    b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        (( s++ ))
    done
    success "$b$d ${S[$s]} of space was cleaned up"
}

function clean() {
    local debug=0
    local withoutDerivedData=0

    local ARGS=`ggetopt --options h,x,d --longoptions help,debug,without-derived-data -n 'Error' -- "$@"`
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
                _usage_of_mac_clean
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -d|--without-derived-data)
                withoutDerivedData=1
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

    # Ask for the administrator password upfront
    sudo -v

    HOST=$( whoami )

    # Keep-alive sudo until `clenaup.sh` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    oldAvailable=$(df / | tail -1 | awk '{print $4}')

    echo 'Empty the Trash on all mounted volumes and the main HDD...'
    sudo \rm -rfv /Volumes/*/.Trashes/* &>/dev/null
    sudo \rm -rfv ~/.Trash/* &>/dev/null

    echo 'Cleanup User Caches...'
    \rm -rfv ~/Library/Caches/* &>/dev/null

    echo 'Clear System Log Files...'
    sudo \rm -rfv /private/var/log/asl/*.asl &>/dev/null
    sudo \rm -rfv /Library/Logs/DiagnosticReports/* &>/dev/null
    sudo \rm -rfv /Library/Logs/Adobe/* &>/dev/null
    \rm -rfv ~/Library/Containers/com.apple.mail/Data/Library/Logs/Mail/* &>/dev/null
    \rm -rfv ~/Library/Logs/CoreSimulator/* &>/dev/null

    echo 'Clear Adobe Cache Files...'
    sudo \rm -rfv ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files/* &>/dev/null

    echo 'Cleanup Application Caches...'
    for x in $(ls ~/Library/Containers/)
    do
        echo "  > Cleanup ~/Library/Containers/$x/Data/Library/Caches/"
        \rm -rfv ~/Library/Containers/$x/Data/Library/Caches/* &>/dev/null
    done

    echo 'Cleanup Quicklook files...'
    sudo \rm -rfv /private/var/folders/ &>/dev/null

    echo 'Cleanup iOS Applications...'
    \rm -rfv ~/Music/iTunes/iTunes\ Media/Mobile\ Applications/* &>/dev/null

    echo 'Remove iOS Device Backups...'
    \rm -rfv ~/Library/Application\ Support/MobileSync/Backup/* &>/dev/null

    echo 'Cleanup Xcode Derived Data...'
    if [[ $withoutDerivedData == 0 ]]; then
        \rm -rfv ~/Library/Developer/Xcode/DerivedData/* &>/dev/null
    fi

    echo 'Cleanup Xcode Archives...'
    \rm -rfv ~/Library/Developer/Xcode/Archives/* &>/dev/null

    echo "Cleanup Xcode EmbeddedAppDeltas"
    \rm -rfv `find /var/folders -type d -name EmbeddedAppDeltas 2>/dev/null`

    if type "xcrun" &>/dev/null; then
        echo 'Cleanup iOS Simulators...'
        osascript -e 'tell application "com.apple.CoreSimulator.CoreSimulatorService" to quit'
        osascript -e 'tell application "iOS Simulator" to quit'
        osascript -e 'tell application "Simulator" to quit'
            xcrun simctl erase all
    fi

    if [ -d "/Users/${HOST}/Library/Caches/CocoaPods" ]; then
        echo 'Cleanup CocoaPods cache...'
        \rm -rfv ~/Library/Caches/CocoaPods/* &>/dev/null
    fi

    # support delete Google Chrome caches
    if [ -d "/Users/${HOST}/Library/Caches/Google/Chrome" ]; then
        echo 'Cleanup Google Chrome cache...'
        \rm -rfv ~/Library/Caches/Google/Chrome/* &> /dev/null
    fi

    # support delete gradle caches
    if [ -d "/Users/${HOST}/.gradle/caches" ]; then
        echo 'Cleanup Gradle cache...'
        \rm -rfv ~/.gradle/caches/ &> /dev/null
    fi

    if type "composer" &> /dev/null; then
        echo 'Cleanup composer...'
        composer clearcache &> /dev/null
    fi

    if type "brew" &>/dev/null; then
        echo 'Cleanup Homebrew Cache...'
        brew cleanup -s &>/dev/null
        #brew cask cleanup &>/dev/null
        \rm -rfv $(brew --cache) &>/dev/null
        brew tap --repair &>/dev/null
    fi

    if type "gem" &> /dev/null; then
        echo 'Cleanup any old versions of gems'
        gem cleanup &>/dev/null
    fi

    if type "docker" &> /dev/null; then
        echo 'Cleanup Docker'
        docker system prune -af
    fi

    echo 'Cleanup pip cache...'
    \rm -rfv ~/Library/Caches/pip

    if [ "$PYENV_VIRTUALENV_CACHE_PATH" ]; then
        echo 'Removing Pyenv-VirtualEnv Cache...'
        \rm -rfv $PYENV_VIRTUALENV_CACHE_PATH &>/dev/null
    fi

    if type "npm" &> /dev/null; then
        echo 'Cleanup npm cache...'
        npm cache clean --force
    fi

    if type "yarn" &> /dev/null; then
        echo 'Cleanup Yarn Cache...'
        yarn cache clean --force
    fi

    echo 'Purge inactive memory...'
    sudo purge

    success 'Success!'

    newAvailable=$(df / | tail -1 | awk '{print $4}')
    count=$((oldAvailable - newAvailable))
    #count=$(( $count * 512))
    _bytes_to_human $count

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

clean $*