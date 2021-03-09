
*  目录
{:toc}

## 环境变量类型报错
在安装或更新 NOX 之后，必须要执行 `source ~/.zshrc` 才能使 NOX 相关环境变量生效。

在编译 NOX 之后，必须要执行 `source ~/.zshrc` 才能使自动补全功能更新。

---

## 私有配置类型报错
类似 gerrit、jira、jenkins 相关的命令会从 `NOX_CONFIG` 中的 `config.yaml` 文件读取配置信息，如：`token`。当用户缺少配置时，命令执行会报错。