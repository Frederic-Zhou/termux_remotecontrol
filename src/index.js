const WebSocket = require('ws')
const request = require('request');

console.log("ServerAddress:", process.argv[2])
let severAddr = process.argv[2]
if (!severAddr) {
    severAddr = "192.168.3.100:8001" //测试地址
}

let ws_minicap
let ws_minitouch
let ws_whatsinput
let ws_scrcpy
let isScreenSending = false
const localhost = "0.0.0.0"

const ws_serv_initiative = new WebSocket(`ws://${severAddr}/websocket/initiative`);

function start_mini(ws_serv_initiative, method) {
    try {
        ws_minicap = new WebSocket(`ws://${localhost}:7912/minicap`);
        ws_minitouch = new WebSocket(`ws://${localhost}:7912/minitouch`);
        ws_whatsinput = new WebSocket(`ws://${localhost}:6677`);
    } catch (error) {
        console.log(error);
    }
    //minicap 事件定义
    ws_minicap.onopen = (ev) => {
        console.log("minicap open")
    };
    ws_minicap.onmessage = (msg) => {
        if (isScreenSending == false) {
            ws_serv_initiative.send(msg.data)
            if (typeof msg.data == "object") {
                isScreenSending = true;
            }
        }
    };
    ws_minicap.onerror = (ev) => {
        ws_minicap.close()
        console.log("minicap error")
    };
    ws_minicap.onclose = (ev) => {
        console.log("minicap close")
    };
    //---------------------------

    //minitouch 事件定义
    ws_minitouch.onopen = (ev) => {
        console.log("minitouch open")
    };
    ws_minitouch.onmessage = (msg) => {
        ws_serv_initiative.send("minitouch:" + msg.data)
        console.log("minitouch:" + msg.data)
    };
    ws_minitouch.onerror = (ev) => {
        ws_minitouch.close()
        console.log("minitouch error")
    };
    ws_minitouch.onclose = (ev) => {
        console.log("minitouch close")
    };
    //---------------------------

    //whatsinput 事件定义
    ws_whatsinput.onopen = (ev) => {
        console.log("whatsinput open")
    };
    ws_whatsinput.onmessage = (msg) => {
        ws_serv_initiative.send("whatsinput:" + msg.data)
        console.log("whatsinput:" + msg.data)
    };
    ws_whatsinput.onerror = (ev) => {
        ws_whatsinput.close()
        console.log("whatsinput error")
    };
    ws_whatsinput.onclose = (ev) => {
        console.log("whatsinput close")
    };
    //---------------------------

    return true
}


function start_scrcpy(ws_serv_initiative, method) {
    try {
        ws_scrcpy = new WebSocket(`ws://${localhost}:8886`);
    } catch (error) {
        console.log(error);
    }
    //ws_scrcpy 事件定义
    ws_scrcpy.onopen = (ev) => {
        console.log("ws_scrcpy open")
    };
    ws_scrcpy.onmessage = (msg) => {
        ws_serv_initiative.send(msg.data)
    };
    ws_scrcpy.onerror = (ev) => {
        ws_scrcpy.close()
        console.log("ws_scrcpy error")
    };
    ws_scrcpy.onclose = (ev) => {
        console.log("ws_scrcpy close")
    };
    //---------------------------

    return true
}



////////////////////////////////////////
let started = false
ws_serv_initiative.onopen = (ev) => {
    console.log("serv ctrl open")
    //读取设备信息，并且发送给服务器
    request(`http://${localhost}:7912/info`, {
        json: false
    }, (err, res, body) => {
        if (err) {
            console.log("http error", err)
            return
        }
        console.log("info1:" + body);
        ws_serv_initiative.send("info:" + body);
    });
};
ws_serv_initiative.onmessage = (msg) => {
    // console.log("receive from server:", msg.data)
    //scrcpy收发都是二进制数据；minicap二进制发送画面，不收数据；minitouch/whatsinput都是收发文本数据
    if (typeof msg.data == "object") { // 收到二进制对象，说明应该是scrcpy模式的数据，直接转发给ws_scrcpy
        ws_scrcpy.send(msg.data)
    } else if (msg.data == "initiative_start_mini" && !started) { //收到开始同屏消息 mini模式
        started = start_mini(ws_serv_initiative)
    } else if (msg.data == "initiative_start_scrcpy" && !started) { //收到开始同屏消息 scrcpy模式
        started = start_scrcpy(ws_serv_initiative)
    } else if (msg.data == "screen_received") { //收到屏幕消息接收完毕的信号(主要是对minicap模式生效)
        isScreenSending = false;
    } else if (msg.data.indexOf("minitouch:") == 0 && started &&
        ws_minitouch.readyState == 1) { //收到minitouch指令
        ws_minitouch.send(msg.data.substr("minitouch:".length))
    } else if (msg.data.indexOf("whatsinput:") == 0 && started &&
        ws_whatsinput.readyState == 1) { //收到whatsinput指令
        ws_whatsinput.send(msg.data.substr("whatsinput:".length))
        console.log(msg.data.substr("whatsinput:".length))
    } else if (msg.data.indexOf("shell:") == 0 && started) { //收到shell指令
        request(`http://${localhost}:7912/shell?command= ${msg.data.substr("shell:".length)}`, {
            json: false
        }, (err, res, body) => {
            if (err) {
                console.log("http error", err)
                return
            }
            console.log("shell:" + body);
            ws_serv_initiative.send("shell:" + body);
        });
    } else if (msg.data == "initiative_stop" && started) {
        started = false
        ws_minicap && ws_minicap.close()
        ws_minitouch && ws_minitouch.close()
        ws_whatsinput && ws_whatsinput.close()
        ws_scrcpy && ws_scrcpy.close()
        console.log("all stoped")
    }
};
ws_serv_initiative.onerror = (ev) => {
    console.log("serv ctrl error")
    ws_serv_initiative.close()
};
ws_serv_initiative.onclose = (ev) => {
    console.log("serv ctrl close")
    started = false
    ws_minicap && ws_minicap.close()
    ws_minitouch && ws_minitouch.close()
    ws_whatsinput && ws_whatsinput.close()
    ws_scrcpy && ws_scrcpy.close()
    process.exit(1)
};

//todo:
// 改用scrcpy 同屏和操作
/*
1. adb push ./scrcpy-server.jar /data/local/tmp/scrcpy-server.jar
2. adb shell CLASSPATH=/data/local/tmp/scrcpy-server.jar nohup app_process / com.genymobile.scrcpy.Server 1.17-ws1 web 8886 2>&1 > /dev/null 
*/