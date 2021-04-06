#!/data/data/com.termux/files/usr/bin/bash
adb version
if [ $? -ne 0 ]; then
    # adb 安装
    pkg install git
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

python3 -c "import uiautomator2"
if [ $? -ne 0 ]; then
    echo "uiautomator2 installing..."
    pkg update

    # 安装必要环境
    pkg install -y python ndk-sysroot clang make libjpeg-turbo libxml2 libxslt termux-api nodejs-lts

    # 升级pip3
    python -m pip3 install --upgrade pip3

    # 安装U2
    pip3 install -U uiautomator2

fi
echo "uiautomator2 installed"
# 初始化一次
sleep 3 # 等待外部的adb tcpip命令生效
python3 -m uiautomator2 init

cp /data/local/tmp/index.js ./index.js

#获得已经安装的nodemodule列表
nodemodule=$(npm ls --depth 0)
if [[ $nodemodule =~ "ws@" ]]; then
    echo "ws Installed"
else
    npm i ws
fi

if [[ $nodemodule =~ "request@" ]]; then
    echo "request Installed"
else
    npm i request
fi

echo "start..."
read -r -p "ServerAddress?[domain:port] " input
node ./index.js $input
echo "over..."
