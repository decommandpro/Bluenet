const WebS = require("ws")
const wss = new WebS.Server({port:8081})

wss.on("connection",ws=>{
    console.log("connection!")
    ws.on("message",msg=>{
        console.log(JSON.stringify({func:msg.toString()}))
        wss.broadcast(JSON.stringify({func:msg.toString()}))
    })
});

wss.broadcast = function broadcast(msg){
    wss.clients.forEach(function each(client) {
        client.send(msg)
    });
};