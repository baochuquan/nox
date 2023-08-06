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

At this point, you might ask if this means you still have to remember a series of subcommands. In fact, you don't. Because nox supports tab completion, you can use the tab key for hints when you forget the available subcommands. When the tab key no longer provides subcommand suggestions, you can enter a '-' and continue pressing the tab key for more hints, which will then display the available options for the command.