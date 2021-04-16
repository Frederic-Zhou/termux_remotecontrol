#安装ATX-agent
adb -t 1 push ./atx-agent /data/local/tmp/atx-agent
adb -t 1 shell chmod 755 /data/local/tmp/atx-agent
adb -t 1 shell /data/local/tmp/atx-agent server -d
echo -e "\033[32m ===ATX-agent INSTALL OVER=== \033[0m"
#adb -t 1 :第一个连接上的设备
adb -t 1 push ./scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
adb -t 1 shell CLASSPATH=/data/local/tmp/scrcpy-server.jar nohup app_process scrcpy-server.jar com.genymobile.scrcpy.Server 1.17-ws1 web 8886 2>&1 >/dev/null &
echo -e "\033[32m ===scrcpy-server.jar INSTALL OVER=== \033[0m"

