

![](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/nox/nox.png)

![Platform](http://img.shields.io/badge/platform-macOS-blue.svg?style=flat)
![Platform](http://img.shields.io/badge/language-zsh-brightgreen.svg?style=flat)
![Platform](http://img.shields.io/badge/tool-homebrew-orange.svg?style=flat)
![Platform](http://img.shields.io/badge/license-MIT-pink.svg?style=flat)

---

你是否还在为执行 shell 脚本时，一层一层的查找脚本路径而感到烦恼？

你是否还在为 shell 脚本参数的琐碎和复杂而感到痛苦？

你是否还在因 `.zshrc` 注册一堆 shell 方法导致难以管理而感到沮丧？

那么，你需要 NOX 来帮你解决使用 Shell 脚本时所遇到一系列困难！

---

## Getting Started
### Features
- **系统调用**：将脚本名称及其路径节点转换为子命令，最终以系统命令的方式进行调用，如：`nox gerrit submit` 将调用 `gerrit` 目录下的 `submit.sh` 脚本进行执行。
- **自动补全**：为所有的脚本及其选项注册自动补全功能，可以加速脚本的调用。
- **帮助提示**：为每个命令提供了帮助提示，只要加上 `--help` 或 `-h` 选项，即可查看命令的功能描述。
- **调试模式**：为每个脚本提供了调试模式，只要加上 `--debug` 或 `-d` 选项，即可查看脚本执行时每一行代码及其运行结果。
- **私有命令**：允许用户创建私有脚本，同时还享受自动补全的功能。

### Installation
**目前只支持 MacOS 系统，前提是用户已经安装了 `zsh` 和 `brew`**。

NOX 的安装仅仅需要三个步骤即可完成：
- 克隆项目
- 执行安装脚本
- 配置生效

首先，执行如下命令，来克隆 NOX 项目（可以在任何目录下执行）。

```shell
$ git clone https://github.com/baochuquan/nox
```

其次，执行如下命令，进入到 NOX 根目录下，执行 `install.sh` 脚本。

```shel
$ cd nox
$ ./install.sh
```

最后，执行如下命令，使 NOX 配置生效。

```shell
$ source ~/.zshrc
```

安装完毕之后，就可以体验 NOX 中的功能了。请见工具索引。

### Update
如下所示，执行系统命令即可更新 NOX，享受最新的功能。

```shell
$ nox system update
```

### Uninstallation
进入到 NOX 根目录下，执行 `uninstall.sh` 脚本，即可卸载。

```shell
$ cd nox
$ ./uninstall.sh
```

---

## Contact
如果你在使用 NOX 中遇到了任何问题，可以通过邮件找 baocq 来帮助你解决问题。

---

## License
The NOX is released under the MIT license.
