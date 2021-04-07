#!/data/data/com.termux/files/usr/bin/bash

#1. 安装必要环境
pkg install -y nodejs-lts termux-api
#####################################################

#2. 如果不存在ADB安装ADB环境
adb version
if [ $? -ne 0 ]; then
    echo "install adb ..."
    # adb 安装
    cp -r /data/local/tmp/adb-ndk ./
    cd ./adb-ndk/bin/
    mv -f adb.bin adb
    chmod +x ./*
    mv -f ./* $PREFIX/bin/
    cd ../..
    rm -rf adb-ndk/
# adb 安装结束
fi
# 启动ADB
sleep 3
adb devices
#####################################################

# 3. 安装uiautomator2
python -c "import uiautomator2"
if [ $? -ne 0 ]; then

    echo "uiautomator2 installing..."
    pkg -y update

    # 安装必要环境
    pkg install -y python ndk-sysroot clang make libjpeg-turbo libxml2 libxslt
    python -m pip install --upgrade pip
    # 安装U2
    pip install -U uiautomator2

fi
echo "uiautomator2 installed"

# 初始化一次
# python -m uiautomator2 init
#####################################################

#4. 部署同屏程序
#copy同屏程序到home目录
cp -r /data/local/tmp/src ./
termux-wake-lock
cd ~/src
npm install
npm start
#######################################################
