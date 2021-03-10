

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-zsh-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

---

NOX 是一个基于 zsh 的 shell 脚本管理工具。

- [Features](#features)
- [Installation](#installation)
- [Update](#update)
- [Uninstalltion](#uninstallation)
- [Usage Examples](#usage-examples)
- [How to add commands to nox](https://github.com/baochuquan/nox/blob/main/docs/how-to-add-commands-to-nox.md)
- [Attention](https://github.com/baochuquan/nox/blob/main/docs/attention.md)
- [About](https://github.com/baochuquan/nox/blob/main/docs/about.md)
- [License](#license)


## Features
- **系统调用**：以 `nox` 为主命令，脚本存储路径、脚本名称作为子命令，进行全局调用。
- **自动补全**：支持 Tab 自动补全，加快命令的索引和调用。
- **帮助选项**：每个命令默认支持帮助提示，通过附加 `--help` 或 `-h` 选项，即可查看命令的功能描述。
- **调试模式**：每个命令默认支持调试模式，通过附加 `--debug` 或 `-d` 选项，即可进入命令的调试模式。
- **私有命令**：支持私有命令，相关脚本文件不会加入 git 管理。

## Installation
**目前只支持 MacOS 系统，安装的前提是已经安装了 `zsh` 和 `brew`**。

NOX 的安装步骤如下，安装时可能会触发 `brew update`。

```shell
# 克隆项目仓库
$ git clone https://github.com/baochuquan/nox

# 执行安装脚本
$ cd nox && ./install.sh

# 配置生效
$ source ~/.zshrc
```

## Update
更新 NOX，体验最新功能，命令如下：

```shell
$ nox system update
```

## Uninstallation
卸载 NOX，命令如下：

```shell
$ cd nox && ./uninstall.sh
```

## Usage Examples

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-life-lunch.gif)

## License
`nox` is released under the MIT license.
