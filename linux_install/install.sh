# 一键配置Termux+adb+uiautomator2+ssh 环境

# 电脑环境要求：Adb
# 手工打开手机开发者模式

check() {
    if [ $? -ne 0 ]; then
        echo -e "\033[31m error \033[0m"
        exit
    fi
}

#打开网络调试端口
adb tcpip 5555
check

sleep 3

#获得已经安装的app列表
packages=$(adb shell pm list packages -3)

if [[ "$packages" =~ "package:com.termux" ]]; then
    echo "termux Installed"
else
    adb install ./apk/termux.apk
    check
fi

if [[ "$packages" =~ "package:com.termux.api" ]]; then
    echo "termux Installed"
else
    adb install ./apk/termux_api.apk
    check
fi

if [[ "$packages" =~ "package:com.buscode.whatsinput" ]]; then
    echo "whatsinput Installed"
else
    adb install ~/termux_remotecontrol/apk/whatsinput.apk
    check
fi

#启动Termux
adb shell am start -n com.termux/.app.TermuxActivity
check

sleep 5 #等待界面打开,把环境脚本拷贝到termux目录。
adb shell input text "cd\ ~\&\&pkg\ install\ -y\ git"
adb shell input text "\&\&rm\ -rf\ ~/termux_remotecontrol"
adb shell input text "\&\&export\ REMOTEHOST=192.168.3.100:8001"
adb shell input text "\&\&git\ clone\ https://github.com/Frederic-Zhou/termux_remotecontrol.git"
adb shell input text "\&\&echo\ \'bash\ ~/termux_remotecontrol/shell/termux_init.sh\'\>.bashrc"
adb shell input text "\&\&bash\ ~/termux_remotecontrol/shell/termux_init.sh"
adb shell input keyevent 66

check

echo 'over!'
