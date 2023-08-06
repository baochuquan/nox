
![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-logo.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Language](http://img.shields.io/badge/language-zsh-brightgreen.svg?style=flat)
![Tool](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)

---

**NOX 解决了什么问题？** NOX 提供了一种优雅地管理 shell 脚本的方式，详见 [《如何优雅地管理你的 shell 脚本？》](http://chuquan.me/2021/04/05/how-to-manage-your-shell-scripts-gracefully/) 一文。

NOX 是一个基于 zsh 的 shell 脚本管理工具。通过编译，可以将符合规范的 shell 脚本转换为以 `nox` 为主命令，脚本路径、脚本名称为子命令的系统命令。同时提供了强大的 Tab 自动补全功能，实现子命令的快速查找。

- [Features](#features)
- [Example](#example)
- [Installation](#installation)
- [Update](#update)
- [Uninstalltion](#uninstallation)
- [How to add commands to nox](https://github.com/baochuquan/nox/blob/main/docs/how-to-add-commands-to-nox.md)
- [Develop tips](https://github.com/baochuquan/nox/blob/main/docs/develop-tips.md)
- [About](https://github.com/baochuquan/nox/blob/main/docs/about.md)
- [License](#license)

## Features
- **系统调用**：以 `nox` 为主命令，脚本存储路径、脚本名称作为子命令，进行全局调用。
- **自动补全**：支持 Tab 自动补全，加快命令的索引和调用。
- **帮助选项**：每个命令默认支持帮助提示，通过附加 `--help` 或 `-h` 选项，即可查看命令的功能描述。
- **调试模式**：每个命令默认支持调试模式，通过附加 `--debug` 或 `-x` 选项，即可进入命令的调试模式。
- **私有命令**：支持私有命令，相关脚本文件不会加入 git 管理。

## Example
关于下图的示例中，
- 首先，我在 `nox/scripts/poker/` 目录下，通过 `nox system create -s ace` 命令创建了一个符合规范的 shell 脚本 `ace.sh`。
- 在开发完具体实现后，通过 `nox system build` 编译生成自动补全逻辑。
- 然后执行 `source ~/.zshrc` 更新自动补全逻辑。
- 最后，输入并结合 Tab 补全，得到下图中的效果。

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox-poker-ace-demo.gif)

关于如何添加子命令，详见 [How to add commands to nox](https://github.com/baochuquan/nox/blob/main/docs/how-to-add-commands-to-nox.md)。

## Installation
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

## License
NOX is released under the MIT license.
