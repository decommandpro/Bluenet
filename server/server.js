console.log("Starting Server")

const WebS = require("ws")
const wss = new WebS.Server({port:8081})

/*wss.on("connection",ws=>{
    console.log("New Connection From ")
    ws.on("message",msg=>{
        console.log(JSON.stringify({func:msg.toString()}))
        wss.broadcast(JSON.stringify({func:msg.toString()}))
    })
});*/

wss.on("connection", function connection(ws, req) {
    console.log("New Connection From: " + req.socket.remoteAddress)
    ws.on("message",msg=>{
        console.log("New Message: " + JSON.stringify({func:msg.toString()}))
        wss.broadcast(JSON.stringify({func:msg.toString()}))
    })
});

wss.broadcast = function broadcast(msg){
    wss.clients.forEach(function each(client) {
        client.send(msg)
    });
};