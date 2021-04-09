#!/data/data/com.termux/files/usr/bin/bash
check() {
    if [ $? -ne 0 ]; then
        echo -e "\033[31m error \033[0m"
        exit
    fi
}

sleep 3

#1. 安装必要环境
echo -e "\033[32m ===NEEDED PACKAGES INSTALL START=== \033[0m"
pkg install -y nodejs-lts termux-api git
echo -e "\033[32m ===NEEDED PACKAGES INSTALL OVER=== \033[0m"
#####################################################

#2. 如果不存在ADB安装ADB环境
echo -e "\033[32m ===ADB INSTALL/RUN START=== \033[0m"
adb version
if [ $? -ne 0 ]; then
    echo "install adb ..."
    # adb 安装
    cd ~
    git clone https://github.com/Magisk-Modules-Repo/adb-ndk.git
    cd ./adb-ndk/bin/
    mv -f adb.bin adb
    chmod +x ./*
    mv -f ./* $PREFIX/bin/
    cd ../..
    rm -rf adb-ndk/
# adb 安装结束
fi
# 启动ADB
adb kill-server
adb devices
echo -e "\033[32m ===ADB INSTALL/RUN OVER=== \033[0m"
sleep 3

#安装scrcpy，并使其打开websocket端口8886
echo -e "\033[32m ===scrcpy-server.jar/ATX-agent INSTALL START=== \033[0m"
adb push ~/termux_remotecontrol/app/scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
adb shell CLASSPATH=/data/local/tmp/scrcpy-server.jar nohup app_process scrcpy-server.jar com.genymobile.scrcpy.Server 1.17-ws1 web 8886 2>&1 >/dev/null &
check
echo -e "\033[32m ===scrcpy-server.jar INSTALL OVER=== \033[0m"
#安装ATX-agent
adb push ~/termux_remotecontrol/app/atx-agent /data/local/tmp/atx-agent
adb shell chmod 755 /data/local/tmp/atx-agent
adb shell /data/local/tmp/atx-agent server -d
check
echo -e "\033[32m ===ATX-agent INSTALL OVER=== \033[0m"
#######################################################
echo -e "\033[32m ===START MAIN=== \033[0m"
termux-wake-lock
cd ~/termux_remotecontrol/src
npm install
npm start
