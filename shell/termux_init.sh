#!/data/data/com.termux/files/usr/bin/bash

#安装必要环境
pkg install python nodejs-lts termux-api
# python -m pip install --upgrade pip

#安装ADB环境
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

# python3 -c "import uiautomator2"
# if [ $? -ne 0 ]; then
#     echo "uiautomator2 installing..."
#     pkg update

#     # 安装必要环境
#     pkg install -y ndk-sysroot clang make libjpeg-turbo libxml2 libxslt

#     # 安装U2
#     pip3 install -U uiautomator2

# fi
# echo "uiautomator2 installed"

# 初始化一次
# sleep 3 # 等待外部的adb tcpip命令生效
# python3 -m uiautomator2 init

#启动同屏程序
cp -r /data/local/tmp/src ./
cd ./src
echo "start..."
read -r -p "ServerAddress?[domain:port] " input
npm install
npm start $input
echo "over..."
