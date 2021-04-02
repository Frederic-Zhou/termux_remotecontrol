#!bin/bash

# 一键配置Termux+adb+uiautomator2+ssh 环境
# 目的
# 1. Termux
# 2. Termux:API
# 3. ADB
# 4. Python3
# 5. UIautomator2
#

## 电脑环境要求
#-  Adb

# 1. 打开手机开发者模式
## 此步骤手工完成

# 2. 下载Termux 和 Termux API 并通过adb命令安装(https://termux.com/)

check() {
    if [ $? -ne 0 ]; then
        echo "\033[31m error \033[0m"
        exit
    fi
}

if [ ! -f "./apk/termux.apk" ]; then
    wget -O ./apk/termux.apk https://f-droid.org/repo/com.termux_108.apk
    check
fi

if [ ! -f "./apk/termux_api.apk" ]; then
    wget -O ./apk/termux_api.apk https://f-droid.org/repo/com.termux.api_47.apk
    check
fi

if [ ! -f "./apk/termux_boot.apk" ]; then
    wget -O ./apk/termux_boot.apk https://f-droid.org/repo/com.termux.boot_7.apk
    check
fi

if [ ! -f "./apk/termux_task.apk" ]; then
    wget -O ./apk/termux_task.apk https://f-droid.org/repo/com.termux.tasker_5.apk
    check
fi

#获得已经安装的app列表
packages=$(adb shell pm list packages)

if [[ "$packages" =~ "package:com.termux" ]]; then
    echo "termux Installed"
else
    adb install ./apk/termux.apk
    check
fi

if [[ "$packages" =~ "package:com.termux.api" ]]; then
    echo "termux.api Installed"
else
    adb install ./apk/termux_api.apk
    check
fi

if [[ "$packages" =~ "package:com.termux.boot" ]]; then
    echo "termux.boot Installed"
else
    adb install ./apk/termux_boot.apk
    check
fi

if [[ "$packages" =~ "package:com.termux.task" ]]; then
    echo "termux.task Installed"
else
    adb install ./apk/termux_task.apk
    check
fi

if [[ "$packages" =~ "package:com.buscode.whatsinput" ]]; then
    echo "whatsinput Installed"
else
    adb install ./apk/whatsinput.apk
    check
fi

#上传自连接脚本
adb push ./index.js /data/local/tmp/index.js
check

#上传脚本和adb安装文件
adb push ./termux_init.sh /data/local/tmp/ti.sh
check
#启动Termux
adb shell am start -n com.termux/.app.TermuxActivity
check
#输入脚本命令
sleep 1
adb shell input text "cp\ \/data\/local\/tmp\/ti\.sh\ \.\/ti\.sh\&\&bash\ \.\/ti\.sh"
check
adb shell input keyevent 66
check

#打开网络调试端口
adb tcpip 5555
check

echo 'over!'
