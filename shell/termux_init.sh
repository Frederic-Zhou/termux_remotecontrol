#!/data/data/com.termux/files/usr/bin/bash
#检查是否已经运行
result=$(ps -ef | grep node)
if [[ "$result" =~ "node index.js" ]]; then
    echo -e "\033[33m started \033[0m"
    exit
fi

sleep 3

#1. 安装必要环境
echo -e "\033[32m ===NEEDED PACKAGES INSTALL START=== \033[0m"
echo 'y\n\n' | pkg update
pkg install -y nodejs-lts git
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

#安装ATX-agent
adb -t 1 push ~/termux_remotecontrol/app/atx-agent /data/local/tmp/atx-agent
adb -t 1 shell chmod 755 /data/local/tmp/atx-agent
adb -t 1 shell /data/local/tmp/atx-agent server -d
echo -e "\033[32m ===ATX-agent INSTALL OVER=== \033[0m"
#adb -t 1 :第一个连接上的设备
adb -t 1 push ~/termux_remotecontrol/app/scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
adb -t 1 shell CLASSPATH=/data/local/tmp/scrcpy-server.jar nohup app_process scrcpy-server.jar com.genymobile.scrcpy.Server 1.17-ws1 web 8886 2>&1 >/dev/null &
echo -e "\033[32m ===scrcpy-server.jar INSTALL OVER=== \033[0m"

#######################################################
echo -e "\033[32m ===START MAIN=== \033[0m"
termux-wake-lock
cd ~/termux_remotecontrol/src
npm install
npm start

# todo
#1. 更新时，有一个地方需要手工确认。解决办法：未解决
#2. 启动时ADB时，需要手工确认，并且必须迅速确认。解决办法：快速确认，勾选允许记住此计算机
#3. 黑屏后，会断开，termux会终止运行。解决办法：手工在手机设置termux允许后台运行，或者设置手机不自动锁频
#4. 重启termux后，需要重新输入服务器地址。解决方案: 在初始化脚本中导入.bashrc的语句，改为两行：
# adb shell input text "\&\&echo\ \'export\ REMOTEHOST=192.168.3.100:8001\'\>.bashrc"
# adb shell input text "\&\&echo\ \'bash\ ~/termux_remotecontrol/shell/termux_init.sh\'\>\>.bashrc"
