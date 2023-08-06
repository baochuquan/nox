![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox03.png)

# 如何为 NOX 添加命令

- [环境变量](#环境变量)
- [创建子命令](#创建子命令)
  - [创建脚本示例](#创建脚本示例)
  - [编写脚本示例](#编写脚本示例)
- [执行脚本](#执行脚本)
- [编译](#编译)
- [调试模式](#调试模式)
- [帮助提示](#帮助提示)
- [小结](#小结)

NOX 本质上是一个 Shell 脚本管理工具，它以系统命令调用的方式来执行指定的脚本，同时提供了自动补全功能，从而帮助用户快速索引脚本。

显然，Shell 脚本才是 NOX 最重要的组成部分。关于 NOX 的开发，其本质上就是如何以 NOX 的规范开发 Shell 脚本。

## 环境变量

在安装 NOX 之后，NOX 项目的根目录下会生成一个 `.noxrc` 文件，该文件内容导入了一系列的环境变量，便于开发者调用，如下所示：
- `NOX_ROOT`：NOX 项目的根目录
- `NOX_NAME`：NOX 系统命令名称
- `NOX_COMMON`：通用工具脚本所存放目录
- `NOX_CONFIG`：NOX 系统配置目录
- `NOX_SCRIPTS`：NOX 管理的 Shell 脚本所存放的根目录
- `NOX_TEMPLATES`：NOX 模板脚本及文件所存放的目录

## 创建子命令

NOX 管理的 Shell 脚本位于 `NOX_SCRIPTS` 目录下，我们可以在该目录下创建脚本或者创建子目录对脚本进行归类。为了让用户创建的子目录和脚本默认遵循 NOX 规范，NOX 通过 `nox system create` 命令，并分别提供了两个选项来帮助用户创建子目录和 Shell 脚本。

**注意：该命令必须在 `NOX_SCRIPTS` 目录及其子目录下执行，否则将会执行失败**。

```shell
# 创建一个名为 <dirname> 的子目录
$ nox system create -d <dirname>

# 创建一个名为 <scriptname> 的 Shell 脚本
$ nox system create -s <scriptname>
```

### 创建目录示例
例如，我们希望创建一个名为 `poker` 的子目录，我们可以在 `NOX_SCRIPTS` 目录下执行如下命令：

```shell
$ nox system create -d poker
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-system-create-poker.gif)

进入新创建的 `poker` 目录，我们会发现该目录下默认生成一个 `.description` 隐藏文件，该文件描述了 `poker` 这个子目录分类下的脚本的主要功能。NOX 自动补全系统会读取 `.description` 中的描述信息。

### 创建脚本示例
在上述例子的基础上，我们进入 `poker` 子目录，创建一个 `ace.sh` 脚本，我们可以执行如下命令（**注：命令中无需添加 `.sh` 后缀**）：

```shell
$ nox system create -s ace
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-system-create-ace.gif)


此时 NOX 在 `poker` 子目录下创建了一个名为 `ace.sh` 的脚本。这个脚本是一个模板脚本，可以直接执行。**注意：由于此时还没有对 NOX 进行编译，此时新建的子目录和脚本都尚未支持自动补全**。我们需要手动输入完整的调用命令来执行 `ace.sh` 脚本，如下所示：

```shell
$ nox poker ace
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-01.gif)

### 编写脚本示例
接下来，我们对 `ace.sh` 脚本进行改写，使其执行能够打印 `A, 2, 3, 4, 5, 6, 7, 9, 10, J, Q, K, Joker`。同时支持两个选项：
- `--count`（短选项：`-c`）：用户需要输入一个值，表示打印的次数。无该选项则表示打印一遍。
- `--reverse`（短选项：`-r`）：开关值选项，有该选项则表示逆序打印，无该选项则表示正序打印。

我们在 `ace.sh` 原有的模板的基础上进行修改。**注意，有几个地方需要进行修改：**
1. `function _usage_of_ace()` 中，我们需要修改 `ace` 的用法、描述、选项及其描述。
2. `function ace()` 中，我们需要将获取变量 `ARGS` 时所执行的 `ggetopt` 命令的输入参数选项修改为我们自定义的长选项和短选项。
3. `fucntion ace()` 中，我们需要在获取选项值的 `while` 循环中，将 `case` 的值修改为我们自定义的长选项和短选项。
4. 加入脚本核心功能的代码逻辑。

最终得到如下结果：

```shell
#!/bin/sh

##############################################################################
##
##  Filename: ace.sh
##  Author: baocq
##  E-mail: baocq@fenbi.com
##  Date: Sun Nov  8 15:27:20 CST 2020
##
##############################################################################

source $NOX_COMMON/utils.sh
source $NOX_COMMON/config.sh

# Usage of ace.sh
function _usage_of_ace() {
    cat << EOF
Usage:
    ace [--count <count>] [-r]

Description:
    ace 相关功能

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --reverse|-r:                                       -- 是否逆序打印，无改选项则正序打印
    --count|-c:                                         -- 打印次数，无该选项则打印一遍

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

function ace() {
    local debug=0
    local reverse=false
    local count=1

    local ARGS=`ggetopt -o hxrc: --long help,debug,reverse,count: -n 'Error' -- "$@"`
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
                _usage_of_ace
                exit 1
                ;;
            -x|--debug)
                debug=1
                shift
                ;;
            -r|--reverse)
                reverse=true
                shift
                ;;
            -c|--count)
                count=$2
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

    # start
    local poker=(A 2 3 4 5 6 7 8 9 10 J Q K Joker)
    
    if [[ $reverse == true ]]; then
        local length=${#poker[*]}
        local tmp=($poker)
        local i=0
        while [[ $i -lt $length ]]; do
            poker[$[$i + 1]]=$tmp[$[$length - $i]]
            i=$[i + 1]
        done
    fi

    local j=0
    while [[ $j < $count ]]; do
        echo $poker
        j=$[j + 1]
    done

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

## 执行脚本
ace $*
```

### 执行脚本
然后，我们就可以执行 `nox poker ace` 并加上相关的选项来执行脚本。

```shell
# 顺序打印扑克牌一遍
$ nox poker ace

# 顺序打印扑克牌两遍
$ nox poker ace -c 2

# 逆序打印扑克牌两遍
$ nox poker ace -c 2 -r
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-02.gif)

## 编译

在创建了子目录、脚本之后，虽然可以通过系统命令的方式调用脚本，如上述例子中，可以通过 `nox poker ace` 来调用脚本，但是却没有自动补全功能。NOX 提供的 `nox system build` 命令就是用于编译生成自动补全文件，编译后会生成一个 `_nox` 文件，存放在 `NOX_ROOT/fpath` 目录下。编译命令执行完成之后，需要通过执行 `source ~/.zshrc` 命令来使之生效，或者重启终端生效。

```shell
$ nox system build

$ source ~/.zshrc
```

执行结果如下所示：

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-system-build-poker-ace.gif)

## 调试模式

通过 `nox system create` 创建的脚本，默认都支持一个 `--debug` 和 `-x` 选项，可以将脚本的执行切换成为调试模式。调试模式能够打印出脚本所执行的每一行代码及其结果，便于开发者进行开发调试。

以 `nox poker ace` 为例，可以采用如下方式使用调试模式执行脚本。

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-debug.gif)

## 帮助提示

通过 `nox system create` 创建的脚本，默认都支持一个 `--help` 和 `-h` 选项，可以打印出该脚本使用说明。每个脚本内部都有一个名为 `_usage_of_脚本名` 的方法，该方法内部定义了该脚本的使用说明。

以 `nox poker ace` 为例，可以采用如下方式查看脚本的使用方法。

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-help.gif)


## 小结

NOX 的开发非常简单，本质上就涉及到两条命令：
- `nox system create`：创建子目录或脚本。
- `nox system build`：编译自动补全。

注意，自动补全编译完成之后，要执行 `source ~/.zshrc` 后才会生效。

