![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-logo.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-zsh-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

# What is nox?
Nox is a zsh-based shell scripts management tool, which can centralizes your scripts and convert them into system commands.

In fact, nox can manage scripts in any programming languages, all you have to do is write a shell script for indirect calls.

# Why is nox?
Every programmer knows that there are two ways to execute a script: by using an absolute path, such as `/User/nox/develop/my-script.sh`, or by using a relative path, such as `./my-script.sh.`. However, it can be quite painful when you want to execute a script in another directory, because you need to know the absolute or relative path of the target script.

Some advanced programmers may define shell scripts in their shell's run control files, such as `.zshrc`, `.bashrc`, etc. However, there are certain issues with this approach, for example, you still have to remember the shell function names you defined. Moreover, without the concept of namespaces, you cannot have functions with the same name.

Fortunately, nox completely solves these problems. It generates a system command with nox as the root command and the path as a subcommand, based on your script's path, allowing you to call it globally. For example, if your script's path is `nox/scripts/poker/ace.sh`, nox will generate a corresponding system command `nox poker ace`. This way, you can globally call the script using this command.

At this point, you might ask if this means you still have to remember a series of subcommands. In fact, you don't. Because nox supports tab completion, you can use the tab key for hints when you forget the available subcommands. When the tab key no longer provides subcommand suggestions, you can enter a `-` and continue pressing the tab key for more hints, which will then display the available options for the command. The following gif demonstrates the command search feature of nox. 

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-example.gif)

# Features
- [x] **System commands**: Nox will generate a system command with `nox` as the root command and the path as the subcommand for every script, which supports global.
- [x] **Auto-completion**: Support Tab auto-completion to speed up command indexing and calling.
- [x] **Help option**: Each command supports help prompts by default. By adding the `--help` or `-h` option, you can view the description of the command.
- [x] **Debug mode**: Each command supports debug mode by default, and you can enter the debug mode of the command by adding the `--debug` or `-x` option.
- [x] **Private commands**: Support private commands, and related script files will not be added to git management.

# Installation
Currently, nox only supports MacOS system, before installing NOX, zsh and brew need to be installed first.

```sh
# clone nox repo
$ git clone https://github.com/baochuquan/nox

# execute install script
$ cd nox && ./install.sh

# let the configuration take effect
$ source ~/.zshrc

```

# Uninstallation
The uninstallation of nox is also very simple, just execute the uninstall.sh script, as shown below.

```sh
$ cd nox && ./uninstall.sh
```

# How to add commands for nox?
The Shell scripts managed by nox are located in the `NOX_SCRIPTS` directory. We can create scripts or subdirectories in this directory to categorize the scripts. In order to have user-created subdirectories and scripts follow the nox specifications by default, nox provides the `nox system create` command with two separate options to help users create subdirectories and Shell scripts.

**Note: This command must be executed in the `NOX_SCRIPTS` directory or its subdirectories, otherwise it will fail to execute.**

```sh
# create a subdirectory named <your-dirname>
$ nox system create -d <your-dirname>

# create a Shell script named <your-scriptname>
$ nox system create -s <your-scriptname>
```

## Create Subcommand
For example, if we want to create a subdirectory named `poker`, we can execute the following command in the `NOX_SCRIPTS` directory:

```sh
$ nox system create -d poker
```

TODO: @baocq

Enter the newly created `poker` directory, we will find that there is a default hidden file named `.description` generated in the directory. This file describes the main functions of the scripts in the `poker` subdirectory category. The nox auto-completion system will read the description information from the `.description` file.

### Create script
Based on the previous example, we can go to the `poker` subdirectory and create an `ace.sh` script by executing the following command (note: there is no need to add the `.sh` extension in the command):

```sh
$ nox system create -s ace
```

TODO: @baocq

At this point, nox has created a script named `ace.sh` in the `poker` subdirectory. This script is a template script that can be executed directly. **Note: Since nox has not been build yet, the newly created subdirectory and script do not support auto-completion**. We need to manually enter the complete invocation command to execute the `ace.sh` script, as shown below:

```sh
$ nox poker ace
```

TODO: @baocq

### Edit Script
Next, let's modify the `ace.sh` script so that it can print A, 2, 3, 4, 5, 6, 7, 9, 10, J, Q, K, Joker. And support two options:
- `--count` (short option: `-c`): The user needs to enter a value, indicating the number of times to print. If this option is not present, it will print once. 
- `--reverse` (short option: `-r`): A toggle value option. If this option is present, it means to print in reverse order; otherwise, print in ascending order.

We will modify the `ace.sh` script based on the existing template. Note that several parts need to be changed:
1. In the function `_usage_of_ace()`, we need to modify the usage, description, options, and their descriptions for `ace`.
2. In the function `ace()`, we need to change the input parameters of the `ggetopt` command executed to get the `ARGS` variable to our custom long and short options.
3. In the function `ace()`, we need to modify the case values in the while loop that gets the option values to our custom long and short options.
4. Add the core code logic of the script.

We finally get the following result:
```sh
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
    nox poker ace [--count <count>] [--reverse]

Description:
    Print poker numbers.

Option:
    --help|-h:                                          -- using help
    --debug|-x:                                         -- debug mode
    --reverse|-r:                                       -- whether to print in reverse order, or print in normal order without this option
    --count|-c:                                         -- the number of times to print, if there is no option, it will be printed once

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
    while [[ $j -lt $count ]]; do
        echo $poker
        j=$[j + 1]
    done

    if [[ $debug == 1 ]]; then
        set +x
    fi
}

# Execute current script
ace $*
```

### Execute Script
After that, we can execute the script by running `nox poker ace` and adding the relevant options.

```sh
# Print the poker cards in order once
$ nox poker ace

# Print the poker cards in order twice
$ nox poker ace -c 2

# Print the poker cards in reverse order twice
$ nox poker ace -c 2 -r
```

TODO: @baocq

## Build
After creating the subdirectories and scripts, although you can call the script through the system command, such as calling the script with `nox poker ace` in the previous example, there is no auto-completion feature. The nox system build command provided by nox is used to compile and generate an auto-completion file. After compilation, a `_nox` file will be generated and stored in the `NOX_ROOT/fpath` directory. After the compilation command is executed, you need to run the `source ~/.zshrc` command to make it take effect, or restart the terminal to make it take effect.

```sh
$ nox system build

$ source ~/.zshrc
```

The execution result is as follows:

TODO: @baocq

## Debug Mode
Scripts created by `nox system create` support a default `--debug` and `-x` option, which can switch the script execution to debug mode. Debug mode can print out each line of code executed by the script and its result, making it convenient for developers to debug.

Taking `nox poker ace` as an example, you can use the following method to execute the script in debug mode.

TODO: @baocq

## Help prompt
Scripts created by nox system create support a default `--help` and `-h` option, which can print out the usage instructions of the script. Inside each script, there is a method named `_usage_of_script_name`, which defines the usage instruction of the script.

Taking nox poker ace as an example, you can use the following method to view the script's usage instructions.

TODO: @baocq

# Develop tips
## Environment variables
After installing nox, a `.noxrc` file will be generated in the root directory of the nox project. The content of this file imports a series of environment variables, which are convenient for developers to call, as follows:
- `NOX_ROOT`: the root directory of nox project.
- `NOX_NAME`: the `nox` command name.
- `NOX_COMMON`: the path of command utils.
- `NOX_CONFIG`: the root directory of scripts that managed by nox.
- `NOX_TEMPLATES`: the directory where NOX template scripts and files are stored.

## Script parameters
Nox requires that each argument in a script has a corresponding option, so as to fully take advantage of the auto-completion feature to simplify script usage. This approach also helps standardize script development.

## Naming conventions
Directory and script names should be composed of numbers, letters, and dashes (-), with the names kept as short as possible.

## Function definition
It is recommended to add the keyword "function" before the function name when defining a function.

Private function names should preferably use an underscore `_` as a prefix.

There should be only one public function per script.

## Function reference
If the `ace.sh` script needs to reference functionality from another script, such as `king.sh`, you can call it using the `nox poker king` command.

Besides, the `NOX_COMMON` directory contains a series of scripts that define a set of utility functions. If the `ace.sh` script needs to reference some utility functions from the `NOX_COMMON` directory, you can execute the source command to import the script file containing the utility function before calling it.

## Private scripts
In the nox repository, the `.gitignore` file states that git will ignore subdirectories or scripts with an underscore `_` prefix. If you want `poker` to act as a private subcommand collection, you can rename poker to `_poker`, and all scripts in its directory will become your private scripts. The auto-completion feature will still be available. However, the command invocation will also change, for example: `nox _poker ace`.

## Tool dependency
`nox/config/brewspec.yaml` is a dependency description file. If your script depends on a specific `brew` tool, you need to describe it in this file. Nox will check and install the tools described in this file during installation or updates.

If the `ace.sh` script depends on other tools that need to be installed through `brew`, you can declare the dependencies in the `brewspec.yaml` file in the `NOX_CONFIG` directory. When users execute `nox system update`, Nox will check and install the tools defined in `brewspec.yaml`.

## Private configuration
`nox/config/config.yaml` is a private configuration file that will not be added to git management.

If the `ace.sh` script needs to read user-specific private configurations, such as the user's LDAP information, these configurations are defined by default in the `config.yaml` file within the `NOX_CONFIG` directory, which will not be included in git management.

## Programming syntax
Nox uses zsh by default to execute scripts, so developers need to be aware of the differences between zsh programming syntax and traditional bash programming syntax. For example, in zsh, arrays are indexed starting from 1, while in bash, arrays are indexed starting from 0.

# License
Nox is released under the MIT license.