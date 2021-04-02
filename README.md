# 使用说明

1. 电脑安装好adb工具
2. 执行 `install.sh` 脚本

## 附:用ssh连接Termux

1. 在termux窗口运行 查看用户名称 `whoami`
2. 在termux窗口运行 设置密码 `passwd`
3. 在termux窗口运行 启动ssh服务端 `sshd`
4. 在termux窗口运行 查看手机IP `ifconfig`
5. 在电脑终端运行 ssh链接 `ssh [用户名]@[IP] -p 8022` (termux默认sshd端口8022)
