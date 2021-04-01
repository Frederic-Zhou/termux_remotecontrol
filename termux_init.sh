#!/bin/sh

pkg update

# 安装必要环境
pkg install -y python ndk-sysroot clang make libjpeg-turbo libxml2 libxslt termux-api git nodejs-lts

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

# 升级pip3
python -m pip3 install --upgrade pip3

# 安装U2
pip3 install -U uiautomator2

# 初始化一次
python3 -m uiautomator2 init

#创建测试
script='import uiautomator2 as u2
d = u2.connect("0.0.0.0")
print(d.info)'

echo "$script" >test.py
python3 test.py
