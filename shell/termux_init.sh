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

#copy同屏程序到home目录
cp -r /data/local/tmp/src ./

# 打开浏览器
adb devices
sleep 3
adb shell am start -a android.intent.action.VIEW -d http://127.0.0.1:8002

#写入自动启动脚本到Termux boot
boot_script='
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
cd ~/src
npm install
npm start
'
mkdir -p ~/.termux/boot/
echo "$boot_script" >~/.termux/boot/runScreen.sh
chmod +x ~/.termux/boot/runScreen.sh
#默认启动一次脚本
bash ~/.termux/boot/runScreen.sh

#todo
#1. 脚本交互自动输入回车
#2. index.js启动好后，自动打开浏览器
