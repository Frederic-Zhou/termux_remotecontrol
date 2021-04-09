# 一键配置Termux+adb+uiautomator2+ssh 环境

# 电脑环境要求：Adb
# 手工打开手机开发者模式

check() {
    if [ $? -ne 0 ]; then
        echo "\033[31m error \033[0m"
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

#安装scrcpy，并使其打开websocket端口8886
# adb push ./app/scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
# adb shell CLASSPATH=/data/local/tmp/scrcpy-server.jar nohup app_process scrcpy-server.jar com.genymobile.scrcpy.Server 1.17-ws1 web 8886 2>&1 >/dev/null &

#安装ATX-agent
# adb push ./app/atx-agent /data/local/tmp
# adb shell chmod 755 /data/local/tmp/atx-agent
# adb shell /data/local/tmp/atx-agent server -d
# check

#上传同屏程序
# adb push ./src/*.* /data/local/tmp/src/
# adb push ./src/view /data/local/tmp/src/
# check

#上传环境初始化文件
# adb push ./shell/termux_init.sh /data/local/tmp/ti.sh
# check

#启动Termux
adb shell am start -n com.termux/.app.TermuxActivity
check

sleep 2 #等待界面打开,把环境脚本拷贝到termux目录。
# adb shell input text "cp\ \/data\/local\/tmp\/ti\.sh\ \.\/ti\.sh\&\&bash\ \.\/ti\.sh"
adb shell input text "cd\ ~\&\&pkg\ install\ -y\ git"
adb shell input text "\&\&rm\ -rf\ ~/termux_remotecontrol"
adb shell input text "\&\&git\ clone\ https://github.com/Frederic-Zhou/termux_remotecontrol.git"
adb shell input text "\&\&echo\ 'bash\ ~/termux_remotecontrol/shell/termux_init.sh'\>.bashrc"
adb shell input text "\&\&bash\ ~/termux_remotecontrol/shell/termux_init.sh"
adb shell input keyevent 66

check

echo 'over!'
