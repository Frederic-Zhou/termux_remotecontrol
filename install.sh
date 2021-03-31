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
if [ ! -f "./apk/termux.apk" ]; then
    wget -O ./apk/termux.apk https://f-droid.org/repo/com.termux_108.apk
fi

if [ ! -f "./apk/termux_api.apk" ]; then
    wget -O ./apk/termux_api.apk https://f-droid.org/repo/com.termux.api_47.apk
fi

if [ ! -f "./apk/termux_boot.apk" ]; then
    wget -O ./apk/termux_boot.apk https://f-droid.org/repo/com.termux.boot_7.apk
fi

if [ ! -f "./apk/termux_task.apk" ]; then
    wget -O ./apk/termux_task.apk https://f-droid.org/repo/com.termux.tasker_5.apk
fi

#获得已经安装的app列表
packages=$(adb shell pm list packages)

if [[ "$packages" =~ "package:com.termux" ]]; then
    echo "termux Installed"
else
    adb install ./apk/termux.apk
fi

if [[ "$packages" =~ "package:com.termux.api" ]]; then
    echo "termux.api Installed"
else
    adb install ./apk/termux_api.apk
fi

if [[ "$packages" =~ "package:com.termux.boot" ]]; then
    echo "termux.boot Installed"
else
    adb install ./apk/termux_boot.apk
fi

if [[ "$packages" =~ "package:com.termux.task" ]]; then
    echo "termux.task Installed"
else
    adb install ./apk/termux_task.apk
fi

#上传脚本和adb安装文件
adb push ./termuxInit.sh /sdcard/ti.sh
adb push ./adb-ndk /sdcard/
#打开网络调试端口
adb tcpip 5555

echo '
Next,run above command on Termux 
sh /sdcard/ti.sh
'
