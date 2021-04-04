const WebSocket = require('ws')
const request = require('request');
// define two ws object 
// ws_minicap connect to mobile
// ws_s connect to sever

let ws_minicap
let ws_minitouch
let ws_whatsinput
const localhost = "0.0.0.0"
let screenSending = false

console.log("ServerAddress:", process.argv[2])
let severAddr = process.argv[2]
if (severAddr == "") {
    console.log("need ServerAddress")
    process.exit(1)
}
const ws_serv_initiative = new WebSocket(`ws://${severAddr}/websocket/initiative`);

function start_transmit(ws_serv_initiative) {
    try {
        ws_minicap = new WebSocket(`ws://${localhost}:7912/minicap`);
        ws_minitouch = new WebSocket(`ws://${localhost}:7912/minitouch`);
        ws_whatsinput = new WebSocket(`ws://${localhost}:6677`);
    } catch (error) {
        console.log(error);
    }


    ws_minicap.onopen = (ev) => {
        console.log("minicap open")
    };
    ws_minicap.onmessage = (msg) => {
        if (screenSending == false) {
            ws_serv_initiative.send(msg.data)
            if (typeof msg.data == "object") {
                screenSending = true;
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
    console.log("receive from server:", msg.data)
    if (msg.data == "initiative_start" && !started) {
        started = start_transmit(ws_serv_initiative)
    } else if (msg.data == "screen_received") {
        screenSending = false;
    } else if (msg.data.indexOf("minitouch:") == 0 && started && ws_minitouch.readyState == 1) {
        ws_minitouch.send(msg.data.substr("minitouch:".length))
    } else if (msg.data.indexOf("whatsinput:") == 0 && started && ws_whatsinput.readyState == 1) {
        ws_whatsinput.send(msg.data.substr("whatsinput:".length))
        console.log(msg.data.substr("whatsinput:".length))
    } else if (msg.data.indexOf("shell:") == 0 && started) {
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
    process.exit(1)
};

//todo:
// 改用scrcpy 同屏和操作
// 画面延迟，因为websocket传输画面太慢