
![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-logo.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-zsh-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

---

[English](https://github.com/baochuquan/nox/README.md)

**NOX 解决了什么问题？** NOX 提供了一种优雅地管理 shell 脚本的方式，详见 [《如何优雅地管理你的 shell 脚本？》](http://chuquan.me/2021/04/05/how-to-manage-your-shell-scripts-gracefully/) 一文。

NOX 是一个基于 zsh 的 shell 脚本管理工具。通过编译，可以将符合规范的 shell 脚本转换为以 `nox` 为主命令，脚本路径、脚本名称为子命令的系统命令。同时提供了强大的 Tab 自动补全功能，实现子命令的快速查找。

- [What is nox?](#what-is-nox)
- [Why is nox?](#why-is-nox)
- [Features](#features)
- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [如何为 nox 添加命令?](#如何为-nox-添加命令?)
    - [创建子命令](#创建子命令)
    - [创建脚本](#创建脚本)
    - [编辑脚本](#编辑脚本)
    - [执行脚本](#执行脚本)
    - [编译](#编译)
    - [调试模式](#调试模式)
    - [帮助提示](#帮助提示)
- [开发提示](#开发提示)
    - [环境变量](#环境变量)
    - [脚本参数](#脚本参数)
    - [命名规范](#命名规范)
    - [函数定义](#函数定义)
    - [函数引用](#函数引用)
    - [私有脚本](#私有脚本)
    - [工具依赖](#工具依赖)
    - [私有配置](#私有配置)
    - [编程语法](#编程语法)
- [License](#license)

## What is nox?

Nox是一款基于 zsh 的脚本管理工具，它可以集中管理你的脚本，并将它们转换为系统命令。

实际上，nox 可以管理任何编程语言的脚本，你只需要编写一个 Shell 脚本，并间接执行脚本即可。

## Why is nox?
每个程序员都知道有两种方法来执行一个脚本：使用绝对路径，例如 `/User/nox/develop/my-script.sh`，或使用相对路径，例如 `./my-script.sh`. 但是，当你想在另一个目录中执行脚本时，这可能会相当痛苦，因为你必须要知道目标脚本的绝对路径或相对路径。

有些程序员可能会在他们的 Shell 运行控制文件中定义 Shell 脚本，例如 `.zshrc`，`.bashrc`等。然而，这种方法存在一定的问题，例如，你仍然需要记住你定义的 Shell 函数名。此外，由于没有命名空间的概念，你不能有同名的函数。

幸运的是，nox 完全解决了这些问题。它根据你的脚本路径生成一个以 nox 为根命令，脚本路径为子命令的系统命令，允许你全局调用它。例如，如果你的脚本路径是 `nox/scripts/poker/ace.sh`，nox 将生成一个相应的系统命令 `nox poker ace`。这样，你就可以使用这个命令全局调用脚本。

此时，你可能会问这是否意味着你仍然需要记住一系列子命令。然而，你并不需要。因为 nox 支持 Tab 自动补全，当你忘记有哪些子命令时，可以使用 Tab 键来查找提示。当 Tab 键不再提供子命令建议时，你可以输入 `-` 并继续 Tab 键以获得更多提示，此时将显示命令支持的选项。以下 gif 展示了 nox 的命令查找功能。

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-demo.gif)

# Features
- **系统调用**：以 `nox` 为主命令，脚本存储路径、脚本名称作为子命令，进行全局调用。
- **自动补全**：支持 Tab 自动补全，加快命令的索引和调用。
- **帮助选项**：每个命令默认支持帮助提示，通过附加 `--help` 或 `-h` 选项，即可查看命令的功能描述。
- **debug mode**：每个命令默认支持debug mode，通过附加 `--debug` 或 `-x` 选项，即可进入命令的debug mode。
- **私有命令**：支持私有命令，相关脚本文件不会加入 git 管理。


# Installation
**目前只支持 MacOS 系统，安装的前提是已经安装了 `zsh` 和 `brew`**。

NOX 的安装步骤如下，安装时可能会触发 `brew update`，一旦触发可能会耗费一些时间来更新 brew，需要耐心等待一下。

```shell
# 克隆项目仓库
$ git clone https://github.com/baochuquan/nox

# 执行安装脚本
$ cd nox && ./install.sh

# 配置生效
$ source ~/.zshrc
```

# Update
更新 NOX，体验最新功能，命令如下：

```sh
$ nox system update
```

## Uninstallation
卸载 NOX，命令如下：

```sh
$ cd nox && ./uninstall.sh
```

# 如何为 nox 添加命令

## 创建子命令

NOX 管理的 Shell 脚本位于 `NOX_SCRIPTS` 目录下，我们可以在该目录下创建脚本或者创建子目录对脚本进行归类。为了让用户创建的子目录和脚本默认遵循 NOX 规范，NOX 通过 `nox system create` 命令，并分别提供了两个选项来帮助用户创建子目录和 Shell 脚本。

**注意：该命令必须在 `NOX_SCRIPTS` 目录及其子目录下执行，否则将会执行失败**。

```sh
# 创建一个名为 <dirname> 的子目录
$ nox system create -d <dirname>

# 创建一个名为 <scriptname> 的 Shell 脚本
$ nox system create -s <scriptname>
```

## 创建目录
例如，我们希望创建一个名为 `poker` 的子目录，我们可以在 `NOX_SCRIPTS` 目录下执行如下命令：

```sh
$ nox system create -d poker
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-system-create-poker.gif)

进入新创建的 `poker` 目录，我们会发现该目录下默认生成一个 `.description` 隐藏文件，该文件描述了 `poker` 这个子目录分类下的脚本的主要功能。NOX 自动补全系统会读取 `.description` 中的描述信息。

## 创建脚本
在上述例子的基础上，我们进入 `poker` 子目录，创建一个 `ace.sh` 脚本，我们可以执行如下命令（**注：命令中无需添加 `.sh` 后缀**）：

```sh
$ nox system create -s ace
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-system-create-ace.gif)


此时 NOX 在 `poker` 子目录下创建了一个名为 `ace.sh` 的脚本。这个脚本是一个模板脚本，可以直接执行。**注意：由于此时还没有对 NOX 进行编译，此时新建的子目录和脚本都尚未支持自动补全**。我们需要手动输入完整的调用命令来执行 `ace.sh` 脚本，如下所示：

```sh
$ nox poker ace
```

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-01.gif)

## 编辑脚本
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

## 执行脚本
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

# Develop tips
## 环境变量

在安装 NOX 之后，NOX 项目的根目录下会生成一个 `.noxrc` 文件，该文件内容导入了一系列的环境变量，便于开发者调用，如下所示：
- `NOX_ROOT`：NOX 项目的根目录
- `NOX_NAME`：NOX 系统命令名称
- `NOX_COMMON`：通用工具脚本所存放目录
- `NOX_CONFIG`：NOX 系统配置目录
- `NOX_SCRIPTS`：NOX 管理的 Shell 脚本所存放的根目录
- `NOX_TEMPLATES`：NOX 模板脚本及文件所存放的目录

## 脚本参数
NOX 要求脚本的每一个参数都要有一个对应选项，从而能够充分利用自动补全功能来简化脚本的使用。

## 命名规范
目录名称和脚本名称使用 **数字、字母、`-`** 进行组合，命名应尽可能短。

## 函数定义
函数定义时建议在函数名之前加上关键字 `function`。

私有函数名建议使用 `_` 作为前缀。

一个脚本中应该只有一个公有函数。

## 函数引用
假如 `ace.sh` 脚本中需要引用其他脚本的功能，如：`king.sh`，可以使用 `nox poker king` 的方式进行调用。

另一方面，`NOX_COMMON` 目录下包含了一系列脚本，这些脚本中定义了一系列的工具方法。假如 `ace.sh` 脚本中需要引用这里面的一些工具方法，可以在调用工具方法之前执行 `source` 命令导入包含该工具方法的脚本文件。

## 私有脚本
NOX 仓库中的 `.gitignore` 文件声明 git 会忽略以 `_` 为前缀的子目录或脚本。假如我们希望 `poker` 作为私有子命令集合，我们可以将 `poker` 改为 `_poker`，那么其目录下的所有脚本都会变成你的私有脚本。同时也能够享有自动补全的功能。只不过，命令的调用也将发生变化，如：`nox _poker ace`。

## 工具依赖
`nox/config/brewspec.yaml` 是一个依赖描述文件，如果你的脚本依赖了某个 brew 工具，需要在此文件中进行描述。NOX 在安装或更新时会检查并安装该文件中所描述的工具。

假如 `ace.sh` 脚本中需要依赖其他的一些工具，而这些工具是需要通过 `brew` 进行安装的，那么我们可以在 `NOX_CONFIG` 的 `brewspec.yaml` 文件中声明所依赖的工具。当用户执行 `nox system update` 时，NOX 会检查并安装 `brewspec.yaml` 中所定义的工具。

## 私有配置
`nox/config/config.yaml` 是一个私有配置文件，该文件不会加入 git 管理。

假如 `ace.sh` 脚本中需要读取用户的私有配置，如用户的 `ldap` 信息，这些配置默认定义在 `NOX_CONFIG` 的 `config.yaml` 文件中，该文件不会被加入 git 管理。

## 编程语法
NOX 默认使用 zsh 执行脚本，因此开发者需要注意 zsh 的编程语法与传统的 bash 编程语法的区别。如：zsh 中数组是从 1 开始索引，而 bash 中数组是从 0 开始索引。

## License
NOX is released under the MIT license.
