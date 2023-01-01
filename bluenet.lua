os.loadAPI("json")
local ws, err = http.websocket("ws://localhost:8081")
local id = math.random(1000, 10000)
return {
    open = function(url, newId)
        ws, err = http.websocket(url)
        if not ws then
            error("Cant connect to specified websocket")
        end
        id = newId
    end,


    send = function(receiveId, msg, protocol)
        local message = {from = id, to = receiveId, protocol = protocol, message = msg}
        ws.send(message)
    end,


    broadcast = function(msg, protocol)
        local message = {from = id, to = "all", protocol = protocol, message = msg}
        ws.send(message)
    end,


    receive = function(protocol, timeout)
        local msg = ws.receive(timeout)
        print(msg)
        local obj = json.decode(msg)
        print(obj)
        local func = load(obj.func)
        print(func)
        local decoded = func()
        print(decoded)

        if decoded.to == id or decoded.to == "all" then
            if protocol then
                if decoded.protocol == protocol then
                    return decoded.from, decoded.message, decoded.protocol
                end
            else
                return decoded.from, decoded.message, decoded.protocol
            end
        end
    end,
}